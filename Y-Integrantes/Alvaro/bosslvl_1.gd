extends CharacterBody2D

# ============================================================================
#  CONFIGURACIÓN DEL BOSS
# ============================================================================
var vida_maxima_fase1 = 600
var velocidad_fase1 = 60
var daño_contacto_fase1 = 15
var daño_especial_fase1 = 25
var rango_ataque = 150

var vida_maxima_fase2 = 400
var velocidad_fase2 = 100
var daño_contacto_fase2 = 25
var daño_especial_fase2 = 40

# ============================================================================
#  VARIABLES
# ============================================================================
var vida_actual = 0
var vida_maxima_actual = 600
var velocidad_actual = 60
var daño_contacto_actual = 15
var daño_especial_actual = 25

var player = null
var empuje = Vector2.ZERO
var puede_atacar = true
var detectado = false
var esta_atacando = false
var puede_rebotar = true
var tiempo_ultimo_rebote = 0
var ultima_direccion = "abajo"
var segunda_fase = false
var barra_cargandose = false
var tiempo_carga = 0
var barra_carga = null
var barra_vida = null
var tiempo_ataque_automatico = 0
var ataque_automatico_activado = false

@onready var anim = $AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea

#=============================================================================
#  INICIALIZACIÓN
#=============================================================================
func _ready():
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemigos")
	
	crear_barras()
	
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_entered)
		detection_area.body_exited.connect(_on_detection_area_exited)
	
	if attack_area:
		attack_area.body_entered.connect(_on_attack_area_entered)
	
	vida_maxima_actual = vida_maxima_fase1
	vida_actual = vida_maxima_fase1
	velocidad_actual = velocidad_fase1
	daño_contacto_actual = daño_contacto_fase1
	daño_especial_actual = daño_especial_fase1
	
	scale = Vector2(1.3, 1.3)
	actualizar_barra_vida()
	
	tiempo_ataque_automatico = 5.0
	
	if anim:
		anim.play("idle")
	
	print("✅ BOSS listo")

func crear_barras():
	# Barra de vida
	barra_vida = ProgressBar.new()
	barra_vida.name = "BarraVida"
	barra_vida.size = Vector2(350, 25)
	barra_vida.position = Vector2(-175, -80)
	barra_vida.visible = false
	add_child(barra_vida)
	
	var style_bg = StyleBoxFlat.new()
	style_bg.bg_color = Color(0.1, 0.05, 0.05)
	style_bg.border_color = Color(0.9, 0.3, 0.1)
	style_bg.border_width_left = 2
	style_bg.border_width_right = 2
	style_bg.border_width_top = 2
	style_bg.border_width_bottom = 2
	style_bg.corner_radius_top_left = 10
	style_bg.corner_radius_top_right = 10
	style_bg.corner_radius_bottom_left = 10
	style_bg.corner_radius_bottom_right = 10
	barra_vida.add_theme_stylebox_override("bg", style_bg)
	
	var label = Label.new()
	label.text = "🔥 GUARDIÁN 🔥"
	label.position = Vector2(100, -22)
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(1, 0.6, 0.2))
	barra_vida.add_child(label)
	
	# Barra de carga
	barra_carga = ProgressBar.new()
	barra_carga.name = "BarraCarga"
	barra_carga.size = Vector2(200, 15)
	barra_carga.position = Vector2(-100, -110)
	barra_carga.visible = false
	barra_carga.max_value = 100
	barra_carga.value = 0
	add_child(barra_carga)
	
	var carga_style = StyleBoxFlat.new()
	carga_style.bg_color = Color(0.05, 0.02, 0.05)
	carga_style.border_color = Color(0.8, 0.2, 0.6)
	carga_style.border_width_left = 2
	carga_style.border_width_right = 2
	carga_style.border_width_top = 2
	carga_style.border_width_bottom = 2
	carga_style.corner_radius_top_left = 8
	carga_style.corner_radius_top_right = 8
	carga_style.corner_radius_bottom_left = 8
	carga_style.corner_radius_bottom_right = 8
	barra_carga.add_theme_stylebox_override("bg", carga_style)
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.9, 0.3, 0.8)
	fill_style.corner_radius_top_left = 6
	fill_style.corner_radius_top_right = 6
	fill_style.corner_radius_bottom_left = 6
	fill_style.corner_radius_bottom_right = 6
	barra_carga.add_theme_stylebox_override("fill", fill_style)
	
	var carga_label = Label.new()
	carga_label.text = "⚡ ACERCÁNDOSE ⚡"
	carga_label.position = Vector2(25, -18)
	carga_label.add_theme_font_size_override("font_size", 10)
	carga_label.add_theme_color_override("font_color", Color(0.9, 0.5, 0.9))
	barra_carga.add_child(carga_label)

func actualizar_barra_vida():
	if barra_vida:
		barra_vida.max_value = vida_maxima_actual
		barra_vida.value = vida_actual
		
		var porcentaje = float(vida_actual) / float(vida_maxima_actual)
		var fill_style = StyleBoxFlat.new()
		if porcentaje > 0.6:
			fill_style.bg_color = Color(0.9, 0.2, 0.1)
		elif porcentaje > 0.3:
			fill_style.bg_color = Color(0.9, 0.5, 0.1)
		else:
			fill_style.bg_color = Color(0.9, 0.7, 0.1)
		fill_style.corner_radius_top_left = 8
		fill_style.corner_radius_top_right = 8
		fill_style.corner_radius_bottom_left = 8
		fill_style.corner_radius_bottom_right = 8
		barra_vida.add_theme_stylebox_override("fill", fill_style)
		
		if barra_vida.has_node("Label"):
			if segunda_fase:
				barra_vida.get_node("Label").text = "💀 GUARDIÁN FURIOSO 💀"
			else:
				barra_vida.get_node("Label").text = "🔥 GUARDIÁN 🔥"

func actualizar_barra_carga(valor):
	if barra_carga:
		barra_carga.value = valor
		if barra_carga.has_node("CargaLabel"):
			var label = barra_carga.get_node("CargaLabel")
			if valor >= 100:
				label.text = "💀 ¡PREPARATE! 💀"
				label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
			else:
				label.text = "⚡ ACERCÁNDOSE ⚡ " + str(int(valor)) + "%"

#=============================================================================
#  DETECCIÓN
#=============================================================================
func _on_detection_area_entered(body):
	if body == player and not detectado:
		detectar_jugador()
	
	if body == player:
		barra_cargandose = true

func _on_detection_area_exited(body):
	if body == player:
		barra_cargandose = false
		tiempo_carga = 0
		actualizar_barra_carga(0)

func detectar_jugador():
	detectado = true
	
	if barra_vida:
		barra_vida.visible = true
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.4, 1.0), 0.1)
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.15)
	
	if anim and anim.sprite_frames.has_animation("idle"):
		anim.play("idle")
	
	print("🎯 BOSS detectó al jugador!")

#=============================================================================
#  ANIMACIONES DE MOVIMIENTO
#=============================================================================
func actualizar_animacion_movimiento(direction: Vector2):
	if not anim or esta_atacando:
		return
	
	if direction == Vector2.ZERO:
		if anim.sprite_frames.has_animation("idle"):
			anim.play("idle")
		return
	
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			if anim.sprite_frames.has_animation("derecha"):
				anim.play("derecha")
			ultima_direccion = "der"
		else:
			if anim.sprite_frames.has_animation("izquierda"):
				anim.play("izquierda")
			ultima_direccion = "izq"
	else:
		if direction.y > 0:
			if anim.sprite_frames.has_animation("abajo"):
				anim.play("abajo")
			ultima_direccion = "abajo"
		else:
			if anim.sprite_frames.has_animation("arriba"):
				anim.play("arriba")
			ultima_direccion = "arriba"

func reproducir_animacion_ataque():
	if not anim:
		return
	
	var anim_name = "ataque_" + ultima_direccion
	
	if anim.sprite_frames.has_animation(anim_name):
		anim.play(anim_name)
	else:
		match ultima_direccion:
			"der":
				if anim.sprite_frames.has_animation("derecha"):
					anim.play("derecha")
			"izq":
				if anim.sprite_frames.has_animation("izquierda"):
					anim.play("izquierda")
			"abajo":
				if anim.sprite_frames.has_animation("abajo"):
					anim.play("abajo")
			"arriba":
				if anim.sprite_frames.has_animation("arriba"):
					anim.play("arriba")

#=============================================================================
#  MOVIMIENTO Y FÍSICA
#=============================================================================
func _physics_process(delta):
	if not player:
		player = get_tree().get_first_node_in_group("player")
		return
	
	if tiempo_ultimo_rebote > 0:
		tiempo_ultimo_rebote -= delta
	
	if barra_cargandose and not detectado:
		barra_carga.visible = true
		tiempo_carga += delta * 30
		if tiempo_carga > 100:
			tiempo_carga = 100
			detectar_jugador()
		actualizar_barra_carga(tiempo_carga)
	elif not detectado:
		if barra_carga:
			barra_carga.visible = false
	
	if not detectado:
		velocity = Vector2.ZERO
		move_and_slide()
		if anim and anim.sprite_frames.has_animation("idle"):
			anim.play("idle")
		return
	
	if esta_atacando:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var distancia = global_position.distance_to(player.global_position)
	var direction = (player.global_position - global_position).normalized()
	empuje = empuje.move_toward(Vector2.ZERO, 200 * delta)
	
	velocity = empuje + (direction * velocidad_actual)
	move_and_slide()
	
	actualizar_animacion_movimiento(direction)
	
	# Rebote
	for i in get_slide_collision_count():
		var colision = get_slide_collision(i)
		var collider = colision.get_collider()
		if (collider == player or (collider and collider.is_in_group("player"))) and tiempo_ultimo_rebote <= 0 and puede_rebotar:
			rebotar_jugador()
			break
	
	# Ataque automático cada 5 segundos (solo si el jugador está cerca)
	if ataque_automatico_activado and detectado and not esta_atacando and puede_atacar:
		if distancia < rango_ataque:
			tiempo_ataque_automatico -= delta
			if tiempo_ataque_automatico <= 0:
				atacar_especial()
				tiempo_ataque_automatico = 5.0

#=============================================================================
#  REBOTE
#=============================================================================
func rebotar_jugador():
	if not puede_rebotar:
		return
	
	tiempo_ultimo_rebote = 0.3
	puede_rebotar = false
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.3, 1.1), 0.05)
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.1)
	
	if player:
		if player.has_method("recibir_dano"):
			player.recibir_dano(daño_contacto_actual)
		player.modulate = Color(1, 0.5, 0.5)
		await get_tree().create_timer(0.15).timeout
		if player:
			player.modulate = Color(1, 1, 1)
	
	await get_tree().create_timer(0.6).timeout
	puede_rebotar = true

#=============================================================================
#  ATAQUE ESPECIAL
#=============================================================================
func atacar_especial():
	if not puede_atacar or esta_atacando:
		return
	
	if player and global_position.distance_to(player.global_position) > rango_ataque:
		tiempo_ataque_automatico = 1.0
		return
	
	puede_atacar = false
	esta_atacando = true
	
	var direccion = (player.global_position - global_position).normalized()
	if abs(direccion.x) > abs(direccion.y):
		ultima_direccion = "der" if direccion.x > 0 else "izq"
	else:
		ultima_direccion = "abajo" if direccion.y > 0 else "arriba"
	
	reproducir_animacion_ataque()
	
	modulate = Color(1, 0.5, 0.5)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.4, 1.2), 0.1)
	
	await get_tree().create_timer(0.4).timeout
	
	if player and is_instance_valid(player):
		if global_position.distance_to(player.global_position) <= rango_ataque + 30:
			if player.has_method("recibir_dano"):
				player.recibir_dano(daño_especial_actual)
			player.modulate = Color(1, 0.3, 0.3)
			await get_tree().create_timer(0.2).timeout
			if player:
				player.modulate = Color(1, 1, 1)
	
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.15)
	modulate = Color(1, 1, 1)
	
	await get_tree().create_timer(0.3).timeout
	if anim and anim.sprite_frames.has_animation("idle"):
		anim.play("idle")
	
	await get_tree().create_timer(1.0).timeout
	puede_atacar = true
	esta_atacando = false

#=============================================================================
#  SEGUNDA FASE
#=============================================================================
func activar_segunda_fase():
	segunda_fase = true
	print("💀 ¡SEGUNDA FASE! 💀")
	
	vida_maxima_actual = vida_maxima_fase2
	vida_actual = vida_maxima_fase2
	velocidad_actual = velocidad_fase2
	daño_contacto_actual = daño_contacto_fase2
	daño_especial_actual = daño_especial_fase2
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 0.8), 0.2)
	tween.tween_property(self, "scale", Vector2(1.4, 1.4), 0.2)
	
	modulate = Color(1, 0.4, 0.4)
	await get_tree().create_timer(0.3).timeout
	modulate = Color(1, 1, 1)
	
	actualizar_barra_vida()
	print("⚡ ¡EL GUARDIÁN SE HA ENFURECIDO! ⚡")

#=============================================================================
#  RECIBIR DAÑO
#=============================================================================
func _on_attack_area_entered(body):
	if body == player and puede_atacar and not esta_atacando and detectado:
		atacar_especial()

func recibir_dano(cantidad):
	if not detectado:
		detectar_jugador()
	
	vida_actual -= cantidad
	vida_actual = max(vida_actual, 0)
	
	print("💚 Boss vida: ", vida_actual, "/", vida_maxima_actual)
	actualizar_barra_vida()
	
	if not ataque_automatico_activado:
		ataque_automatico_activado = true
		tiempo_ataque_automatico = 5.0
		print("⚔️ Temporizador de ataque automático activado!")
	else:
		tiempo_ataque_automatico = 5.0
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 0.3, 0.3), 0.05)
	tween.tween_property(self, "modulate", Color(1, 0.7, 0.7), 0.1)
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1)
	tween.parallel().tween_property(self, "scale", Vector2(1.4, 1.2), 0.08)
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.12)
	
	if player:
		var direction_from_player = (global_position - player.global_position).normalized()
		empuje = direction_from_player * 150
	
	if not segunda_fase and vida_actual <= vida_maxima_actual * 0.4:
		activar_segunda_fase()
	
	if vida_actual <= 0:
		morir()

#=============================================================================
#  MUERTE - DESBLOQUEAR PASO AL NIVEL 2 Y RECOMPENSAS
#=============================================================================
func morir():
	print("💀 BOSS DERROTADO! 💀")
	
	# Animación de muerte
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.8, 0.3), 0.3)
	tween.parallel().tween_property(self, "modulate", Color(1, 0.2, 0.2, 1), 0.3)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.4)
	tween.parallel().tween_property(self, "scale", Vector2(0.3, 0.3), 0.4)
	
	# Ocultar barras
	if barra_vida:
		var tween_barra = create_tween()
		tween_barra.tween_property(barra_vida, "modulate:a", 0, 0.3)
	if barra_carga:
		var tween_carga = create_tween()
		tween_carga.tween_property(barra_carga, "modulate:a", 0, 0.3)
	
	# ========================================================================
	#  ABRIR PASO AL NIVEL 2
	# ========================================================================
	var puerta = get_node("/root/Node2D/BOSS_LVL1/Habitación/Puerta")
	if puerta:
		# 1. Ocultar y desactivar marcos
		var marco1 = puerta.get_node_or_null("Marco_Puerta")
		if marco1:
			marco1.visible = false
			if marco1.has_method("set_collision_enabled"):
				marco1.set_collision_enabled(false)
			print("✅ Marco_Puerta desactivado")
		
		var marco2 = puerta.get_node_or_null("Marco_Puerta2")
		if marco2:
			marco2.visible = false
			if marco2.has_method("set_collision_enabled"):
				marco2.set_collision_enabled(false)
			print("✅ Marco_Puerta2 desactivado")
		
		# 2. Activar avanzar_lvl2 (sin colisión)
		var avanzar = puerta.get_node_or_null("avanzar_lvl2")
		if avanzar:
			avanzar.visible = true
			if avanzar.has_method("set_collision_enabled"):
				avanzar.set_collision_enabled(false)
			print("✅ avanzar_lvl2 activado")
		
		# Buscar el TileMapLayer que actúa como pared física (cambia "NombreTileMapPared" por el nombre real)
		var pared_fisica = get_node("/root/Node2D/BOSS_LVL1/Habitación/Puerta/avanzar_lvl2")
		if pared_fisica and pared_fisica.has_method("set_collision_enabled"):
			pared_fisica.set_collision_enabled(false)
			print("✅ Colisión de la pared física desactivada")
		
		# 3. Activar área de teletransporte (Area2D)
		var area_teleport = get_node("/root/Node2D/BOSS_LVL1/Habitación/Area2D")
		if area_teleport:
			area_teleport.monitoring = true
			area_teleport.process_mode = Node.PROCESS_MODE_INHERIT
			print("✅ Área de teletransporte ACTIVADA")
		else:
			print("❌ No se encontró Area2D")
	
	# ========================================================================
	#  SUMAR AL CONTADOR DE JEFE
	# ========================================================================
	var var_enemigos = get_node("/root/Node2D/Var_Enemigos")
	if var_enemigos:
		var_enemigos.sumar_jefe()
	
	# ========================================================================
	#  RECOMPENSAS (CARTAS)
	# ========================================================================
	var cartas = [
		{"tipo": 0, "valor": 50, "ruta": "res://Y-Integrantes/Iker/carta heal.png"},
		{"tipo": 1, "valor": 15, "ruta": "res://Y-Integrantes/Iker/carta ataque.png"},
		{"tipo": 2, "valor": 150, "ruta": "res://Y-Integrantes/Iker/carta speed.png"},
		{"tipo": 3, "valor": 15, "ruta": "res://Y-Integrantes/Iker/carta fuego.png"}
	]
	var cantidad_cartas = randi() % 3 + 2
	for i in range(cantidad_cartas):
		var carta_elegida = cartas[randi() % cartas.size()]
		var carta_scene = preload("res://carta.tscn")
		var carta = carta_scene.instantiate()
		carta.position = global_position + Vector2(randf_range(-100, 100), randf_range(-60, 60))
		carta.tipo = carta_elegida["tipo"]
		carta.valor = carta_elegida["valor"]
		get_parent().add_child(carta)
	
	await get_tree().create_timer(0.8).timeout
	queue_free()
	
