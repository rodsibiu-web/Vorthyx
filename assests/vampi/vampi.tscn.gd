extends CharacterBody2D

# ============================================================================
#  CONFIGURACIÓN DEL JEFE VAMPIRO
# ============================================================================
@export var velocidad = 200
@export var velocidad_furia = 280
@export var vida_maxima_fase1 = 7500
@export var vida_maxima_fase2 = 7500
@export var daño_ataque = 35
@export var daño_ataque_furia = 60
@export var tiempo_entre_ataques = 1.5
@export var tiempo_pre_ataque = 0.8
@export var fuerza_rebote_jugador = 600
@export var fuerza_retroceso_vampiro = 300
@export var distancia_retroceso = 45
@export var ruta_escena_victoria = "res://escenas/Victoria.tscn"

# Preload de la escena de victoria para evitar errores
const ESCENA_VICTORIA = preload("res://escenas/Victoria.tscn")

# ============================================================================
#  VARIABLES PRINCIPALES
# ============================================================================
var player = null
var detectado = false
var puede_atacar = true
var esta_atacando = false
var preparando_ataque = false
var ultima_direccion = "abajo"
var empuje = Vector2.ZERO
var muriendo = false
var tiempo_desde_ultimo_ataque = 0
var tiempo_preparacion = 0
var segunda_fase = false
var multiplicador_daño_recibido = 1.0

# ============================================================================
#  VARIABLES DE VIDA
# ============================================================================
var vida_actual = 7500
var vida_maxima_actual = 7500
var velocidad_actual = 200
var daño_ataque_actual = 35

# ============================================================================
#  REFERENCIAS A NODOS
# ============================================================================
@onready var anim = $AnimatedSprite2D
@onready var detection_area = $Area_detectar
@onready var attack_area = $Area_ataque
@onready var barra_vida = $BarraVida
@onready var collision_shape = $CollisionShape2D

#=============================================================================
#  INICIALIZACIÓN
#=============================================================================
func _ready():
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemigos")
	
	vida_actual = vida_maxima_fase1
	vida_maxima_actual = vida_maxima_fase1
	velocidad_actual = velocidad
	daño_ataque_actual = daño_ataque
	multiplicador_daño_recibido = 1.0
	
	crear_barra_vida()
	
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_entered)
	
	if attack_area:
		attack_area.body_entered.connect(_on_attack_area_entered)
		attack_area.collision_mask = 1
	
	print("✅ Jefe Vampiro listo - FASE 1")

func crear_barra_vida():
	if not has_node("BarraVida"):
		barra_vida = ProgressBar.new()
		barra_vida.name = "BarraVida"
		barra_vida.max_value = vida_maxima_actual
		barra_vida.value = vida_actual
		barra_vida.show_percentage = false
		barra_vida.position = Vector2(-45, -60)
		barra_vida.size = Vector2(90, 10)
		add_child(barra_vida)
		
		var label = Label.new()
		label.name = "Label"
		label.text = "⚔️ VAMPIRO ⚔️"
		label.position = Vector2(20, -20)
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
		barra_vida.add_child(label)
	
	var estilo_fondo = StyleBoxFlat.new()
	estilo_fondo.bg_color = Color(0.1, 0.05, 0.05, 0.9)
	barra_vida.add_theme_stylebox_override("bg", estilo_fondo)
	
	var estilo_lleno = StyleBoxFlat.new()
	estilo_lleno.bg_color = Color(0.8, 0.1, 0.1)
	barra_vida.add_theme_stylebox_override("fill", estilo_lleno)

func actualizar_barra_vida():
	if barra_vida:
		barra_vida.max_value = vida_maxima_actual
		barra_vida.value = vida_actual
		
		var porcentaje = float(vida_actual) / float(vida_maxima_actual)
		var fill_style = StyleBoxFlat.new()
		
		if segunda_fase:
			if porcentaje > 0.6:
				fill_style.bg_color = Color(0.9, 0.2, 0.4)
			elif porcentaje > 0.3:
				fill_style.bg_color = Color(0.9, 0.5, 0.2)
			else:
				fill_style.bg_color = Color(0.9, 0.7, 0.1)
		else:
			if porcentaje > 0.6:
				fill_style.bg_color = Color(0.8, 0.1, 0.1)
			elif porcentaje > 0.3:
				fill_style.bg_color = Color(0.8, 0.4, 0.1)
			else:
				fill_style.bg_color = Color(0.8, 0.7, 0.1)
		
		barra_vida.add_theme_stylebox_override("fill", fill_style)
		
		if barra_vida.has_node("Label"):
			if segunda_fase:
				barra_vida.get_node("Label").text = "💀 VAMPIRO FURIA 💀"
				barra_vida.get_node("Label").add_theme_color_override("font_color", Color(1, 0.5, 0.2))
			else:
				barra_vida.get_node("Label").text = "⚔️ VAMPIRO ⚔️"
				barra_vida.get_node("Label").add_theme_color_override("font_color", Color(1, 0.3, 0.3))

#=============================================================================
#  ACTIVAR SEGUNDA FASE
#=============================================================================
func activar_segunda_fase():
	if segunda_fase:
		return
	
	segunda_fase = true
	print("💀 ¡SEGUNDA FASE ACTIVADA! 💀")
	
	modulate = Color(1, 0.5, 0.5)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.4, 0.8), 0.2)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
	
	vida_actual = vida_maxima_fase2
	vida_maxima_actual = vida_maxima_fase2
	velocidad_actual = velocidad_furia
	daño_ataque_actual = daño_ataque_furia
	multiplicador_daño_recibido = 5.0
	
	actualizar_barra_vida()
	
	# Aura simple
	var aura = ColorRect.new()
	aura.color = Color(1, 0.2, 0.1, 0.3)
	aura.size = Vector2(180, 180)
	aura.position = Vector2(-90, -90)
	add_child(aura)
	
	var aura_tween = create_tween()
	aura_tween.tween_property(aura, "modulate:a", 0, 1.5)
	await aura_tween.finished
	aura.queue_free()
	
	await get_tree().create_timer(0.5).timeout
	modulate = Color(1, 1, 1)
	
	print("⚡ El vampiro se ha enfurecido! Recibirá x5 de daño!")

#=============================================================================
#  DETECCIÓN
#=============================================================================
func _on_detection_area_entered(body):
	if body == player and not detectado:
		detectado = true
		print("🧛 Jefe Vampiro detectó al jugador")

#=============================================================================
#  MOVIMIENTO
#=============================================================================
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
	
	if preparando_ataque:
		tiempo_preparacion += delta
		if tiempo_preparacion >= tiempo_pre_ataque:
			preparando_ataque = false
			ejecutar_ataque()
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if detectado and not esta_atacando and vida_actual > 0 and not muriendo and not preparando_ataque:
		var direction = (player.global_position - global_position).normalized()
		empuje = empuje.move_toward(Vector2.ZERO, 300 * delta)
		velocity = empuje + (direction * velocidad_actual)
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
	
	if not esta_atacando and not muriendo and not preparando_ataque:
		actualizar_animaciones()

func actualizar_animaciones():
	if not anim:
		return
	
	if velocity.length() > 5:
		match ultima_direccion:
			"der": anim.play("der")
			"izq": anim.play("izq")
			"abajo": anim.play("abajo")
			"arriba": anim.play("arriba")
	else:
		anim.play("ilde")

#=============================================================================
#  ATAQUE
#=============================================================================
func _on_attack_area_entered(body):
	if body == player and puede_atacar and detectado and vida_actual > 0 and not esta_atacando and not muriendo and not preparando_ataque:
		iniciar_ataque()

func iniciar_ataque():
	puede_atacar = false
	preparando_ataque = true
	tiempo_preparacion = 0
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

func ejecutar_ataque():
	esta_atacando = true
	
	var anim_ataque = "ataque_" + ultima_direccion
	if anim.sprite_frames.has_animation(anim_ataque):
		anim.play(anim_ataque)
	else:
		match ultima_direccion:
			"der": anim.play("der")
			"izq": anim.play("izq")
			"abajo": anim.play("abajo")
			"arriba": anim.play("arriba")
	
	await get_tree().create_timer(0.4).timeout
	
	if player and is_instance_valid(player) and player.has_method("recibir_dano"):
		if attack_area and player in attack_area.get_overlapping_bodies():
			player.recibir_dano(daño_ataque_actual)
			print("⚔️ Vampiro ataca! Daño: ", daño_ataque_actual)
			
			var direccion_rebote = (player.global_position - global_position).normalized()
			player.global_position += direccion_rebote * 70
			
			if player is CharacterBody2D:
				player.velocity = direccion_rebote * fuerza_rebote_jugador
				player.move_and_slide()
			
			player.modulate = Color(1, 0.5, 0.5)
			await get_tree().create_timer(0.15).timeout
			if player:
				player.modulate = Color(1, 1, 1)
			
			var direccion_retroceso = -direccion_rebote
			global_position += direccion_retroceso * distancia_retroceso
			empuje = direccion_retroceso * fuerza_retroceso_vampiro
	
	await get_tree().create_timer(0.2).timeout
	
	esta_atacando = false

#=============================================================================
#  RECIBIR DAÑO
#=============================================================================
func recibir_dano(cantidad):
	if vida_actual <= 0 or muriendo:
		return
	
	var daño_real = cantidad * multiplicador_daño_recibido
	
	vida_actual -= daño_real
	if vida_actual < 0:
		vida_actual = 0
	
	print("💚 Vampiro vida: ", vida_actual, "/", vida_maxima_actual)
	print("   Daño recibido: ", daño_real, " (multiplicador x", multiplicador_daño_recibido, ")")
	actualizar_barra_vida()
	
	modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(1.0).timeout
	modulate = Color(1, 1, 1)
	
	if player:
		var direccion_retroceso = (global_position - player.global_position).normalized()
		global_position += direccion_retroceso * 30
		empuje = direccion_retroceso * 250
	
	# ACTIVAR SEGUNDA FASE
	if not segunda_fase and vida_actual <= 0:
		vida_actual = vida_maxima_fase2
		activar_segunda_fase()
	elif vida_actual <= 0:
		morir()

#=============================================================================
#  MUERTE - VA A LA ESCENA DE VICTORIA
#=============================================================================
func morir():
	if muriendo:
		return
	muriendo = true
	
	print("💀 Jefe Vampiro derrotado!")
	
	# Desactivar todo
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
	
	# Animación de muerte
	if anim and anim.sprite_frames.has_animation("muerte"):
		anim.play("muerte")
		await anim.animation_finished
	else:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.2, 0.5), 0.3)
		tween.tween_property(self, "modulate:a", 0, 0.3)
		await tween.finished
	
	# Mostrar mensaje
	print("🎉 ¡VICTORIA! Esperando 10 segundos antes de cambiar de escena...")
	
	# Soltar recompensas
	soltar_recompensa()
	
	# Esperar 10 segundos y cambiar a la escena de victoria
	await get_tree().create_timer(3).timeout
	
	# Cambiar a la escena de victoria usando preload
	get_tree().change_scene_to_packed(ESCENA_VICTORIA)
	print("✅ Cambiando a escena de victoria")

#=============================================================================
#  RECOMPENSAS
#=============================================================================
func soltar_recompensa():
	var cartas = [
		{"tipo": "VIDA", "valor": 50, "ruta": "res://Y-Integrantes/Iker/carta heal.png"},
		{"tipo": "ESPADA", "valor": 15, "ruta": "res://Y-Integrantes/Iker/carta ataque.png"},
		{"tipo": "BOTA", "valor": 150, "ruta": "res://Y-Integrantes/Iker/carta speed.png"},
		{"tipo": "FUEGO", "valor": 15, "ruta": "res://Y-Integrantes/Iker/carta fuego.png"}
	]
	
	var cantidad_cartas = 3 if segunda_fase else 2
	
	for i in range(cantidad_cartas):
		var carta_elegida = cartas[randi() % cartas.size()]
		var carta_scene = preload("res://carta.tscn")
		var carta = carta_scene.instantiate()
		carta.position = global_position + Vector2(randf_range(-80, 80), randf_range(-50, 50))
		carta.tipo = obtener_tipo_enum(carta_elegida["tipo"])
		carta.valor = carta_elegida["valor"]
		get_parent().add_child(carta)
	
	print("✨ El vampiro ha soltado ", cantidad_cartas, " cartas")

func obtener_tipo_enum(tipo_str):
	match tipo_str:
		"VIDA": return 0
		"ESPADA": return 1
		"BOTA": return 2
		"FUEGO": return 3
	return 0

func is_alive():
	return vida_actual > 0 and not muriendo
