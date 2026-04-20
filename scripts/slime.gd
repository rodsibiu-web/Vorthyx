extends CharacterBody2D

var vida = 200
var vida_maxima = 200
var jugador_objetivo = null
var empuje = Vector2.ZERO
var puede_atacar = true

# ========== EXPERIENCIA ==========
var experiencia_otorgada = 70  # Experiencia que da al morir

# ========== SISTEMA DE QUEMADURA ==========
var quemadura_activa = false
var daño_quemadura = 0
var tiempo_quemadura = 0.0
var timer_quemadura = null
var duracion_total = 0

@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea
@onready var barra_vida = $BarraVida

# ========== CARTAS QUE PUEDE SOLTAR ==========
var cartas_posibles = [
	{"tipo": "VIDA", "valor": 20, "ruta": "res://Y-Integrantes/Iker/carta heal.png"},
	{"tipo": "ESPADA", "valor": 5, "ruta": "res://Y-Integrantes/Iker/carta ataque.png"},
	{"tipo": "BOTA", "valor": 50, "ruta": "res://Y-Integrantes/Iker/carta speed.png"},
	{"tipo": "FUEGO", "valor": 5, "ruta": "res://Y-Integrantes/Iker/carta fuego.png"}
]

# ========== ORBE DE EXPERIENCIA ==========
var orbe_experiencia_scene = preload("res://orbe.experiencia.tscn")

func _ready():
	add_to_group("enemigos")
	
	# Configurar barra de vida
	crear_barra_vida()
	
	# Configurar timer de quemadura
	timer_quemadura = Timer.new()
	timer_quemadura.wait_time = 1.0
	timer_quemadura.one_shot = false
	timer_quemadura.timeout.connect(_aplicar_daño_quemadura)
	add_child(timer_quemadura)
	
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_entered)
		detection_area.body_exited.connect(_on_detection_area_exited)
	
	if attack_area:
		attack_area.body_entered.connect(_on_attack_area_entered)
		attack_area.collision_mask = 1

func crear_barra_vida():
	if not has_node("BarraVida"):
		barra_vida = ProgressBar.new()
		barra_vida.name = "BarraVida"
		add_child(barra_vida)
	
	barra_vida.max_value = vida_maxima
	barra_vida.value = vida
	barra_vida.show_percentage = false
	barra_vida.position = Vector2(-35, -45)
	barra_vida.size = Vector2(70, 8)
	barra_vida.add_theme_stylebox_override("fill", crear_estilo_barra(Color.RED))
	barra_vida.add_theme_stylebox_override("bg", crear_estilo_barra(Color(0.2, 0.2, 0.2, 0.7)))

func crear_estilo_barra(color: Color):
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	return style

func actualizar_barra_vida():
	if barra_vida:
		barra_vida.value = vida

func _on_detection_area_entered(body):
	if (body.is_in_group("player") or body.is_in_group("player2")) and jugador_objetivo == null:
		jugador_objetivo = body
		print("👁️ Slime detecta a: ", body.name)

func _on_detection_area_exited(body):
	if body == jugador_objetivo:
		jugador_objetivo = null
		print("👁️ Slime perdió a: ", body.name)

func _physics_process(delta):
	actualizar_barra_vida()
	
	if jugador_objetivo == null:
		velocity = Vector2.ZERO
		move_and_slide()
		if animated_sprite.animation != "Idle":
			animated_sprite.play("Idle")
		return
	
	var direction = (jugador_objetivo.global_position - global_position).normalized()
	empuje = empuje.move_toward(Vector2.ZERO, 500 * delta)
	velocity = empuje + (direction * 80)
	move_and_slide()
	
	for i in get_slide_collision_count():
		var colision = get_slide_collision(i)
		if colision.get_collider() == jugador_objetivo:
			var normal = colision.get_normal()
			empuje = normal * 400
			position += normal * 10
	
	if velocity.length() > 5:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0:
				animated_sprite.play("derecha")
			else:
				animated_sprite.play("izquierda")
		else:
			if velocity.y > 0:
				animated_sprite.play("abajo")
			else:
				animated_sprite.play("arriba")
	else:
		animated_sprite.play("Idle")

func _on_attack_area_entered(body):
	if (body.is_in_group("player") or body.is_in_group("player2")) and puede_atacar:
		if body == jugador_objetivo:
			atacar(body)

func atacar(jugador):
	puede_atacar = false
	print("⚔️ Slime ataca a: ", jugador.name)
	
	if jugador and jugador.has_method("recibir_dano"):
		jugador.recibir_dano(10)
	
	await get_tree().create_timer(1.0).timeout
	puede_atacar = true

# ========== SISTEMA DE QUEMADURA ==========

func aplicar_quemadura(daño, duracion):
	if daño <= 0 or duracion <= 0:
		return
	
	print("🔥 Aplicando quemadura: ", daño, " daño/segundo durante ", duracion, " segundos")
	
	daño_quemadura = daño
	duracion_total = duracion
	tiempo_quemadura = duracion
	
	if not quemadura_activa:
		quemadura_activa = true
		timer_quemadura.start()
		print("🔥 Timer de quemadura iniciado")
	else:
		print("🔥 Quemadura renovada")
	
	modulate = Color(1, 0.5, 0)

func _aplicar_daño_quemadura():
	if tiempo_quemadura <= 0:
		timer_quemadura.stop()
		quemadura_activa = false
		modulate = Color(1, 1, 1)
		print("🔥 La quemadura terminó después de ", duracion_total, " segundos")
		return
	
	recibir_dano(daño_quemadura)
	print("🔥 Daño por quemadura: ", daño_quemadura, " (", int(tiempo_quemadura), "s restantes)")
	
	tiempo_quemadura -= 1

# ========== FIN SISTEMA QUEMADURA ==========

func recibir_dano(cantidad):
	vida -= cantidad
	if vida < 0:
		vida = 0
	
	print("❤️ Slime vida: ", vida, "/", vida_maxima)
	actualizar_barra_vida()
	
	modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	
	if not quemadura_activa:
		modulate = Color(1, 1, 1)
	else:
		modulate = Color(1, 0.5, 0)
	
	if vida <= 0:
		morir()

# ========== SOLTAR CARTA ALEATORIA AL MORIR ==========

func soltar_carta():
	"""Crea una carta en el mundo al morir el slime (10% de probabilidad)"""
	var probabilidad = randi() % 100  # Número entre 0 y 99
	
	if probabilidad < 10:  # 10% de probabilidad
		# Elegir carta aleatoria
		var carta_elegida = cartas_posibles[randi() % cartas_posibles.size()]
		print("🍃 El slime ha soltado una carta: ", carta_elegida["tipo"])
		
		# Cargar la escena de la carta
		var carta_scene = preload("res://carta.tscn")
		var carta_instancia = carta_scene.instantiate()
		
		# Configurar la carta
		carta_instancia.set_script(preload("res://cartas.gd"))
		carta_instancia.tipo = obtener_tipo_enum(carta_elegida["tipo"])
		carta_instancia.valor = carta_elegida["valor"]
		
		# Posicionar la carta donde murió el slime
		carta_instancia.global_position = global_position
		
		# Añadir al mundo
		get_parent().add_child(carta_instancia)
		
		print("✨ Carta de ", carta_elegida["tipo"], " generada en el suelo")

func obtener_tipo_enum(tipo_str):
	match tipo_str:
		"VIDA":
			return 0  # TipoCarta.VIDA
		"ESPADA":
			return 1  # TipoCarta.ESPADA
		"BOTA":
			return 2  # TipoCarta.BOTA
		"FUEGO":
			return 3  # TipoCarta.FUEGO
	return 0

# ========== SOLTAR ORBE DE EXPERIENCIA ==========

func soltar_orbe_experiencia():
	"""Crea un orbe de experiencia al morir el slime"""
	if orbe_experiencia_scene:
		var orbe = orbe_experiencia_scene.instantiate()
		orbe.global_position = global_position
		orbe.experiencia = experiencia_otorgada
		get_parent().add_child(orbe)
		print("🌟 Orbe de experiencia creado! +", experiencia_otorgada, " XP")
	else:
		print("⚠️ No se pudo crear el orbe de experiencia - escena no cargada")

# ========== FIN SOLTAR ORBE ==========

func morir():
	print("💀 Slime muerto")
	
	if timer_quemadura and timer_quemadura.is_stopped() == false:
		timer_quemadura.stop()
	
	# SOLTAR ORBE DE EXPERIENCIA (SIEMPRE)
	soltar_orbe_experiencia()
	
	# Intentar soltar una carta (10% de probabilidad)
	soltar_carta()
	
	var contador = get_tree().get_first_node_in_group("contador")
	if contador and contador.has_method("sumar_slime"):
		contador.sumar_slime()
	
	queue_free()

func is_alive():
	return vida > 0
