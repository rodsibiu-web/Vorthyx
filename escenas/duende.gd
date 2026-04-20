extends CharacterBody2D

@export var velocidad = 300
@export var vida = 600
@export var vida_maxima = 600
@export var daño_ataque = 30
@export var tiempo_entre_ataques = 1.2
@export var fuerza_rebote_jugador = 500
@export var fuerza_retroceso_orco = 300
@export var distancia_retroceso = 60
@export var fuerza_retroceso_daño = 250

var player = null
var detectado = false
var puede_atacar = true
var esta_atacando = false
var ultima_direccion = "abajo"
var empuje = Vector2.ZERO
var muriendo = false
var tiempo_desde_ultimo_ataque = 0
var puerta1_abierta = false
var puerta2_abierta = false
var puerta_quitar_abierta = false  # Variable para Quitar_Puerta

# ========== EXPERIENCIA ==========
var experiencia_otorgada = 80

# ========== CARTAS ==========
var cartas_posibles = [
	{"tipo": "VIDA", "valor": 30},
	{"tipo": "ESPADA", "valor": 10},
	{"tipo": "BOTA", "valor": 80},
	{"tipo": "FUEGO", "valor": 10}
]

# ========== REFERENCIAS ==========
@onready var anim = $AnimatedSprite2D
@onready var detection_area = $detection_area
@onready var attack_area = $attack_area
@onready var barra_vida = $BarraVida
@onready var collision_shape = $CollisionShape2D

# Cargar la escena del orbe
var orbe_experiencia_scene = preload("res://orbe.experiencia.tscn")

func _ready():
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemigos")
	crear_barra_vida()
	
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_entered)
	if attack_area:
		attack_area.body_entered.connect(_on_attack_area_entered)
		attack_area.collision_mask = 1

func crear_barra_vida():
	if not has_node("BarraVida"):
		barra_vida = ProgressBar.new()
		barra_vida.name = "BarraVida"
		barra_vida.max_value = vida_maxima
		barra_vida.value = vida
		barra_vida.show_percentage = false
		barra_vida.position = Vector2(-30, -48)
		barra_vida.size = Vector2(60, 6)
		add_child(barra_vida)
	
	var estilo_fondo = StyleBoxFlat.new()
	estilo_fondo.bg_color = Color(0.1, 0.05, 0.05, 0.9)
	barra_vida.add_theme_stylebox_override("bg", estilo_fondo)
	
	var estilo_lleno = StyleBoxFlat.new()
	estilo_lleno.bg_color = Color(0.8, 0.2, 0.1)
	barra_vida.add_theme_stylebox_override("fill", estilo_lleno)

func actualizar_barra_vida():
	if barra_vida:
		barra_vida.value = vida

func _on_detection_area_entered(body):
	if body == player and not detectado:
		detectado = true

func _physics_process(delta):
	if not player:
		player = get_tree().get_first_node_in_group("player")
		return
	
	actualizar_barra_vida()
	
	if not puede_atacar:
		tiempo_desde_ultimo_ataque += delta
		if tiempo_desde_ultimo_ataque >= tiempo_entre_ataques:
			puede_atacar = true
			tiempo_desde_ultimo_ataque = 0
	
	if detectado and not esta_atacando and vida > 0 and not muriendo:
		var direction = (player.global_position - global_position).normalized()
		empuje = empuje.move_toward(Vector2.ZERO, 300 * delta)
		velocity = empuje + (direction * velocidad)
		move_and_slide()
		
		if velocity.length() > 5:
			if abs(velocity.x) > abs(velocity.y):
				if velocity.x > 0:
					ultima_direccion = "der"
				else:
					ultima_direccion = "izq"
			else:
				if velocity.y > 0:
					ultima_direccion = "abajo"
				else:
					ultima_direccion = "arriba"
	else:
		velocity = Vector2.ZERO
		move_and_slide()
	
	if not esta_atacando and not muriendo:
		actualizar_animaciones()

func actualizar_animaciones():
	if not anim:
		return
	if velocity.length() > 5:
		match ultima_direccion:
			"der": anim.play("derecha")
			"izq": anim.play("izquierda")
			"abajo": anim.play("abajo")
			"arriba": anim.play("arriba")
	else:
		anim.play("idle")

func _on_attack_area_entered(body):
	if body == player and puede_atacar and detectado and vida > 0 and not esta_atacando and not muriendo:
		atacar()

func atacar():
	if esta_atacando or not puede_atacar:
		return
	
	puede_atacar = false
	esta_atacando = true
	tiempo_desde_ultimo_ataque = 0
	velocity = Vector2.ZERO
	
	var direccion = (player.global_position - global_position).normalized()
	
	if abs(direccion.x) > abs(direccion.y):
		if direccion.x > 0:
			ultima_direccion = "der"
		else:
			ultima_direccion = "izq"
	else:
		if direccion.y > 0:
			ultima_direccion = "abajo"
		else:
			ultima_direccion = "arriba"
	
	var anim_ataque = "attack_" + ultima_direccion
	if anim.sprite_frames.has_animation(anim_ataque):
		anim.play(anim_ataque)
	else:
		match ultima_direccion:
			"der": anim.play("derecha")
			"izq": anim.play("izquierda")
			"abajo": anim.play("abajo")
			"arriba": anim.play("arriba")
	
	await get_tree().create_timer(0.4).timeout
	
	if player and is_instance_valid(player) and player.has_method("recibir_dano"):
		if attack_area and player in attack_area.get_overlapping_bodies():
			player.recibir_dano(daño_ataque)
			var direccion_rebote = (player.global_position - global_position).normalized()
			player.global_position += direccion_rebote * 60
			if player is CharacterBody2D:
				player.velocity = direccion_rebote * fuerza_rebote_jugador
				player.move_and_slide()
			player.modulate = Color(1, 0.5, 0.5)
			await get_tree().create_timer(0.15).timeout
			if player:
				player.modulate = Color(1, 1, 1)
			var direccion_retroceso = -direccion_rebote
			global_position += direccion_retroceso * distancia_retroceso
			empuje = direccion_retroceso * fuerza_retroceso_orco
	
	await get_tree().create_timer(0.2).timeout
	esta_atacando = false

func recibir_dano(cantidad):
	if vida <= 0 or muriendo:
		return
	vida -= cantidad
	if vida < 0:
		vida = 0
	actualizar_barra_vida()
	modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.15).timeout
	modulate = Color(1, 1, 1)
	if player:
		var direccion_retroceso = (global_position - player.global_position).normalized()
		global_position += direccion_retroceso * 25
		empuje = direccion_retroceso * fuerza_retroceso_daño
	if vida <= 0:
		morir()

# ========== SOLTAR ORBE DE EXPERIENCIA ==========
func soltar_orbe_experiencia():
	print("🔴 DEBUG: Creando orbe de experiencia...")
	
	if orbe_experiencia_scene:
		var orbe = orbe_experiencia_scene.instantiate()
		orbe.global_position = global_position
		orbe.experiencia = experiencia_otorgada
		
		# Añadir al nivel principal
		get_tree().current_scene.add_child(orbe)
		print("🌟 Orbe creado en: ", global_position, " XP: ", experiencia_otorgada)
	else:
		print("❌ ERROR: No se pudo cargar la escena del orbe")

# ========== SOLTAR CARTA ==========
func soltar_carta():
	var probabilidad = randi() % 100
	if probabilidad < 30:
		var carta_elegida = cartas_posibles[randi() % cartas_posibles.size()]
		print("🍃 Carta soltada: ", carta_elegida["tipo"])

# ========== ABRIR PUERTAS ==========
func abrir_puerta_1():
	print("🚪 Puerta 1 abierta (3 duendes)")
	var puerta = get_tree().root.find_child("PASAR_HABITACIÓN", true, false)
	if not puerta:
		puerta = get_tree().root.find_child("PASAR_HABITACION", true, false)
	if puerta:
		puerta.visible = false
		if puerta.has_method("clear"):
			puerta.clear()
	
	var marco1 = get_tree().root.find_child("Marco 1", true, false)
	if marco1:
		marco1.visible = false
	var marco2 = get_tree().root.find_child("Marco 2", true, false)
	if marco2:
		marco2.visible = false

func abrir_puerta_2():
	print("🚪 Puerta 2 abierta (7 duendes)")
	var puerta = get_tree().root.find_child("SIGUIENTE_HABITACION", true, false)
	if puerta:
		puerta.visible = false
		if puerta.has_method("clear"):
			puerta.clear()

func abrir_quitar_puerta():
	print("🚪 Quitar_Puerta desactivada (11 duendes)")
	
	# Buscar el nodo Quitar_Puerta
	var quitar_puerta = get_tree().root.find_child("Quitar_Puerta", true, false)
	if quitar_puerta:
		quitar_puerta.visible = false
		quitar_puerta.queue_free()  # Eliminarlo
		print("✅ Quitar_Puerta eliminado")
	else:
		print("⚠️ No se encontró Quitar_Puerta")

# ========== MORIR ==========
# ========== MORIR ==========
# ========== MORIR ==========
func morir():
	if muriendo:
		return
	muriendo = true
	
	print("💀 Duende muerto!")
	
	if collision_shape:
		collision_shape.disabled = true
	if detection_area:
		detection_area.monitoring = false
	if attack_area:
		attack_area.monitoring = false
	if barra_vida:
		barra_vida.visible = false
	
	velocity = Vector2.ZERO
	esta_atacando = true
	
	# ========== SOLTAR ORBE DE EXPERIENCIA ==========
	soltar_orbe_experiencia()
	
	# ========== ABRIR PUERTAS ==========
	var contador = get_tree().get_first_node_in_group("contador")
	if contador:
		contador.sumar_duende_habitacion1()
		
		print("🔴 CONTADOR ACTUAL: ", contador.duendes_habitacion1)
		
		# Puerta 1: EXACTAMENTE 3 duendes
		if contador.duendes_habitacion1 == 3 and not puerta1_abierta:
			puerta1_abierta = true
			abrir_puerta_1()
		
		# Puerta 2: EXACTAMENTE 7 duendes
		if contador.duendes_habitacion1 == 7 and not puerta2_abierta:
			puerta2_abierta = true
			abrir_puerta_2()
		
		# ========== CAMBIADO: Quitar_Puerta con 18 duendes (7 + 11) ==========
		if contador.duendes_habitacion1 == 18 and not puerta_quitar_abierta:
			puerta_quitar_abierta = true
			abrir_quitar_puerta()
	
	# ========== ANIMACIÓN DE MUERTE ==========
	if anim and anim.sprite_frames.has_animation("muerte"):
		anim.play("muerte")
		await anim.animation_finished
	else:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.2, 0.5), 0.2)
		tween.tween_property(self, "modulate:a", 0, 0.2)
		await tween.finished
	
	# ========== SOLTAR CARTA ==========
	soltar_carta()
	
	queue_free()
