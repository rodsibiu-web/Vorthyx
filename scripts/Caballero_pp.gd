extends CharacterBody2D

@export var speed = 300.0
@export var camera_smooth_speed = 5.0

@onready var anim = $AnimatedSprite2D
@onready var camera = $Camera2D

var inventory_panel = null
var atacando = false
var ultima_direccion = "abajo"
var vida = 10
var max_vida = 10
var ataque_daño = 3
var hitbox = null
var corazones = []

# ========== SISTEMA DE QUEMADURA ==========
var daño_quemadura = 0
var duracion_quemadura = 0

# ========== SISTEMA DE EXPERIENCIA Y NIVELES ==========
var nivel = 1
var experiencia_actual = 0
var experiencia_necesaria = 100

# Stats base (nivel 1)
var stat_ataque_base = 3
var stat_velocidad_base = 300

# Puntos por nivel
var puntos_por_nivel_ataque = 1
var puntos_por_nivel_velocidad = 8
var curacion_al_subir = 3

# Barra de experiencia
var barra_experiencia = null
var canvas_layer = null
var nivel_texto = null

# ========== MODO OP ==========
var modo_op_activado = false
var color_original_anim = Color.WHITE

# ========== FUNCIONES DE VIDA Y CORAZONES ==========

func _ready():
	cargar_inventario_ui()
	add_to_group("player")
	
	# Guardar color original del AnimatedSprite2D
	if anim:
		color_original_anim = anim.modulate
	
	if camera:
		camera.enabled = true
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = camera_smooth_speed
	
	hitbox = $HitboxAtq
	if hitbox == null:
		hitbox = $Area2D
	if hitbox == null:
		hitbox = find_child("HitboxAtq", true, false)
	if hitbox == null:
		hitbox = find_child("Area2D", true, false)
	
	if hitbox:
		hitbox.visible = false
		hitbox.monitoring = false
		hitbox.body_entered.connect(_on_hitbox_entered)
	
	inicializar_corazones()
	crear_barra_experiencia()
	
	max_vida = contar_corazones_visibles()
	vida = max_vida
	ataque_daño = stat_ataque_base
	speed = stat_velocidad_base
	
	actualizar_corazones()
	actualizar_barra_experiencia()
	
	print("✅ Jugador iniciado - Nivel ", nivel)

func cargar_inventario_ui():
	var panel_scene = preload("res://escenas/InventoryPanel.tscn")
	inventory_panel = panel_scene.instantiate()
	add_child(inventory_panel)

func inicializar_corazones():
	var heart_node = $heart
	if heart_node:
		for child in heart_node.get_children():
			if child is HBoxContainer or child is VBoxContainer:
				for corazon in child.get_children():
					if corazon is TextureRect:
						corazones.append(corazon)
				break
	print("✅ Corazones encontrados: ", corazones.size())

func contar_corazones_visibles():
	return corazones.size()

func actualizar_corazones():
	for i in range(corazones.size()):
		if i < vida:
			corazones[i].modulate = Color(1, 1, 1)
		else:
			if corazones[i].modulate == Color(1, 1, 1):
				corazones[i].modulate = Color(0.3, 0.3, 0.3)

func curar_corazones(cantidad):
	var curacion = min(cantidad, max_vida - vida)
	vida += curacion
	actualizar_corazones()
	print("❤️ Curado +", curacion, " corazones (", vida, "/", max_vida, ")")

# ========== BARRA DE EXPERIENCIA ==========

func crear_barra_experiencia():
	canvas_layer = CanvasLayer.new()
	canvas_layer.name = "UICanvas"
	add_child(canvas_layer)
	
	var marco = PanelContainer.new()
	marco.position = Vector2(15, 48)
	marco.size = Vector2(350, 70)
	canvas_layer.add_child(marco)
	
	var marco_style = StyleBoxFlat.new()
	marco_style.bg_color = Color(0, 0, 0, 0.5)
	marco_style.border_color = Color(0.8, 0.5, 0.2)
	marco_style.border_width_left = 2
	marco_style.border_width_right = 2
	marco_style.border_width_top = 2
	marco_style.border_width_bottom = 2
	marco_style.corner_radius_top_left = 10
	marco_style.corner_radius_top_right = 10
	marco_style.corner_radius_bottom_left = 10
	marco_style.corner_radius_bottom_right = 10
	marco.add_theme_stylebox_override("panel", marco_style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("margin_left", 10)
	vbox.add_theme_constant_override("margin_top", 8)
	vbox.add_theme_constant_override("margin_right", 10)
	vbox.add_theme_constant_override("margin_bottom", 8)
	marco.add_child(vbox)
	
	nivel_texto = Label.new()
	nivel_texto.text = "🌟 NIVEL " + str(nivel) + " 🌟"
	nivel_texto.add_theme_font_size_override("font_size", 16)
	nivel_texto.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	nivel_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(nivel_texto)
	
	barra_experiencia = ProgressBar.new()
	barra_experiencia.name = "BarraExperiencia"
	barra_experiencia.size = Vector2(320, 16)
	barra_experiencia.max_value = experiencia_necesaria
	barra_experiencia.value = experiencia_actual
	barra_experiencia.show_percentage = false
	vbox.add_child(barra_experiencia)
	
	var style_bg = StyleBoxFlat.new()
	style_bg.bg_color = Color(0.15, 0.1, 0.2)
	style_bg.border_color = Color(0.5, 0.3, 0.7)
	style_bg.border_width_left = 2
	style_bg.border_width_right = 2
	style_bg.border_width_top = 2
	style_bg.border_width_bottom = 2
	style_bg.corner_radius_top_left = 5
	style_bg.corner_radius_top_right = 5
	style_bg.corner_radius_bottom_left = 5
	style_bg.corner_radius_bottom_right = 5
	barra_experiencia.add_theme_stylebox_override("bg", style_bg)
	
	var xp_texto = Label.new()
	xp_texto.text = str(experiencia_actual) + " / " + str(experiencia_necesaria) + " XP"
	xp_texto.add_theme_font_size_override("font_size", 12)
	xp_texto.add_theme_color_override("font_color", Color(0.7, 0.9, 1.0))
	xp_texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(xp_texto)
	
	nivel_texto.set_meta("xp_texto", xp_texto)
	
	actualizar_barra_experiencia()

func actualizar_barra_experiencia():
	if not barra_experiencia:
		return
	
	barra_experiencia.max_value = experiencia_necesaria
	barra_experiencia.value = experiencia_actual
	
	var porcentaje = float(experiencia_actual) / float(experiencia_necesaria)
	var style_fill = StyleBoxFlat.new()
	if porcentaje > 0.66:
		style_fill.bg_color = Color(0.3, 0.8, 0.4)
	elif porcentaje > 0.33:
		style_fill.bg_color = Color(0.4, 0.6, 1.0)
	else:
		style_fill.bg_color = Color(0.7, 0.4, 1.0)
	style_fill.corner_radius_top_left = 4
	style_fill.corner_radius_top_right = 4
	style_fill.corner_radius_bottom_left = 4
	style_fill.corner_radius_bottom_right = 4
	barra_experiencia.add_theme_stylebox_override("fill", style_fill)
	
	if nivel_texto:
		nivel_texto.text = "🌟 NIVEL " + str(nivel) + " 🌟"
		
		if nivel_texto.has_meta("xp_texto"):
			var xp_texto = nivel_texto.get_meta("xp_texto")
			xp_texto.text = str(experiencia_actual) + " / " + str(experiencia_necesaria) + " XP"

# ========== SISTEMA DE EXPERIENCIA ==========

func recibir_experiencia(cantidad):
	experiencia_actual += cantidad
	print("✨ +", cantidad, " XP! (", experiencia_actual, "/", experiencia_necesaria, ")")
	
	# Efecto visual de ganar XP
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 0.5), 0.1)
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.2)
	
	actualizar_barra_experiencia()
	
	while experiencia_actual >= experiencia_necesaria:
		subir_nivel()

# CORREGIDO: método set_loops sin errores
func subir_nivel():
	var nivel_anterior = nivel
	
	experiencia_actual -= experiencia_necesaria
	nivel += 1
	experiencia_necesaria = 100 + (nivel * 15)
	
	var curacion = curacion_al_subir + randi() % 2
	curar_corazones(curacion)
	
	ataque_daño += puntos_por_nivel_ataque
	speed += puntos_por_nivel_velocidad
	
	efecto_subir_nivel()
	actualizar_barra_experiencia()
	
	print("🎉 ¡SUBISTE DE NIVEL! ", nivel_anterior, " → ", nivel, " 🎉")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("   ❤️ Curado: +", curacion, " corazones (", vida, "/", max_vida, ")")
	print("   ⚔️ Daño: +", puntos_por_nivel_ataque, " (Total: ", ataque_daño, ")")
	print("   👢 Velocidad: +", puntos_por_nivel_velocidad, " (Total: ", speed, ")")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

func efecto_subir_nivel():
	# CORREGIDO: Primero las animaciones, luego set_loops
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.25, 0.75), 0.08)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.08)
	tween.set_loops(4)
	
	var flash = create_tween()
	flash.tween_property(self, "modulate", Color(1, 1, 0.3), 0.1)
	flash.tween_property(self, "modulate", Color(1, 1, 0.8), 0.1)
	flash.tween_property(self, "modulate", Color(1, 1, 1), 0.2)

# ========== MOVIMIENTO Y ATAQUE ==========

func _physics_process(delta):
	if Input.is_action_just_pressed("pausa"):
		get_tree().change_scene_to_file("res://escenas/Pausa.tscn")
		return
	
	var direction = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	if direction.length() > 1.0:
		direction = direction.normalized()
	
	velocity = direction * speed
	move_and_slide()
	
	if Input.is_action_just_pressed("ataque") and not atacando:
		atacar()
		return
	
	if not atacando:
		actualizar_animaciones(direction)

func actualizar_animaciones(direction: Vector2):
	if direction == Vector2.ZERO:
		anim.play("idle")
		return
	
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			anim.play("der")
			ultima_direccion = "der"
		else:
			anim.play("izq")
			ultima_direccion = "izq"
	else:
		if direction.y > 0:
			anim.play("abajo")
			ultima_direccion = "abajo"
		else:
			anim.play("arriba")
			ultima_direccion = "arriba"

func atacar():
	if hitbox == null:
		return
	
	atacando = true
	velocity = Vector2.ZERO
	
	modulate = Color(1.5, 1.2, 1.2)
	await get_tree().create_timer(0.05).timeout
	modulate = Color(1, 1, 1)
	
	var mouse_pos = get_global_mouse_position()
	var player_pos = global_position
	var direccion = (mouse_pos - player_pos).normalized()
	
	if abs(direccion.x) > abs(direccion.y):
		if direccion.x > 0:
			hitbox.position = Vector2(25, 0)
			anim.play("ataque_der")
		else:
			hitbox.position = Vector2(-25, 0)
			anim.play("ataque_izq")
	else:
		if direccion.y > 0:
			hitbox.position = Vector2(0, 25)
			anim.play("ataque_abajo")
		else:
			hitbox.position = Vector2(0, -25)
			anim.play("ataque_arriba")
	
	hitbox.visible = true
	hitbox.monitoring = true
	
	await get_tree().create_timer(0.8).timeout
	
	hitbox.visible = false
	hitbox.monitoring = false
	atacando = false

func _on_hitbox_entered(body):
	if body.is_in_group("enemigos"):
		print("⚔️ Golpe al enemigo!")
		
		if body.has_method("recibir_dano"):
			body.recibir_dano(ataque_daño * 10)
		
		if daño_quemadura > 0 and body.has_method("aplicar_quemadura"):
			body.aplicar_quemadura(daño_quemadura, duracion_quemadura)

# ========== FUNCIÓN PARA GANAR EXPERIENCIA DESDE ORBES ==========
# Esta es la función que llama el orbe
func ganar_experiencia(cantidad):
	recibir_experiencia(cantidad)

func recibir_dano(cantidad):
	# MODO OP: INMORTAL
	if modo_op_activado:
		print("🛡️ MODO OP ACTIVADO - Daño ignorado!")
		return
	
	var perdidos = cantidad / 10
	for i in range(perdidos):
		if vida > 0:
			vida -= 1
			actualizar_corazones()
			print("💔 Corazones: ", vida, "/", max_vida)
			await get_tree().create_timer(0.1).timeout
	
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.2).timeout
	modulate = Color(1, 1, 1)
	
	if vida <= 0:
		morir()

func morir():
	print("💀 JUGADOR MUERTO")
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 0.5, 0.5, 0), 0.5)
	await tween.finished
	get_tree().change_scene_to_file("res://escenas/Derrota.tscn")

# ========== FUNCIÓN PONERSE AMARILLO ==========
func ponerse_amarillo():
	if anim:
		anim.modulate = Color.YELLOW
		print("🟡 Personaje AMARILLO")
		
		# Volver a color original después de 1 segundo
		await get_tree().create_timer(1.0).timeout
		if not modo_op_activado:
			anim.modulate = color_original_anim

# ========== FUNCIONES PARA EFECTOS DE CARTAS ==========

func curar(cantidad):
	var curacion = cantidad / 10
	vida += curacion
	if vida > max_vida:
		vida = max_vida
	actualizar_corazones()
	print("❤️ Curado +", curacion, " corazones")

func aumentar_dano(cantidad):
	ataque_daño += cantidad
	print("⚔️ Daño aumentado +", cantidad)

func aumentar_velocidad(cantidad):
	speed += cantidad
	print("👢 Velocidad aumentada +", cantidad)

func mejorar_quemadura(incremento_daño, incremento_duracion):
	daño_quemadura += incremento_daño
	duracion_quemadura += incremento_duracion
	print("🔥 Quemadura mejorada")

# ========== SISTEMA DE CARTAS ==========

func recoger_carta(tipo: String, valor: float, ruta_imagen: String):
	Global.cartas_recogidas.append({
		"tipo": tipo,
		"valor": valor,
		"ruta_imagen": ruta_imagen
	})
	print("📦 Carta recogida: ", tipo)

func mostrar_cartas():
	if Global.cartas_recogidas.size() == 0:
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		print("📦 NO HAS RECOGIDO NINGUNA CARTA")
		print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
		return
	
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("📦 MIS CARTAS (", Global.cartas_recogidas.size(), ")")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	
	for i in range(Global.cartas_recogidas.size()):
		var carta = Global.cartas_recogidas[i]
		var icono = ""
		match carta["tipo"]:
			"VIDA": icono = "❤️"
			"ESPADA": icono = "⚔️"
			"BOTA": icono = "👢"
			"FUEGO": icono = "🔥"
		print(str(i+1) + ". " + icono + " " + carta["tipo"] + " +" + str(carta["valor"]))
	
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("📊 EFECTOS ACUMULADOS:")
	print("   ⚔️ Daño: ", ataque_daño)
	print("   👢 Velocidad: ", speed)
	print("   🔥 Quemadura: ", daño_quemadura, " daño/s")
	print("   🌟 Nivel: ", nivel)
	print("   ❤️ Corazones: ", vida, "/", max_vida)
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

# ========== MODO OP - ACTIVAR CON Ctrl + Shift + O ==========

func activar_modo_op():
	if modo_op_activado:
		print("⚠️ MODO OP ya está activado")
		return
	
	modo_op_activado = true
	
	# Guardar velocidad original
	var velocidad_original = speed
	
	# Multiplicar velocidad por 3
	speed = speed * 3
	
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("🔥 ¡¡¡ MODO OP ACTIVADO !!! 🔥")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	print("   💀 Inmortalidad activada")
	print("   ⚔️ Daño aumentado a 10,000")
	print("   👢 Velocidad x3: ", speed)
	print("   🟡 Personaje en modo AMARILLO")
	print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
	
	# Activar modo OP
	ataque_daño = 10000
	
	# PONERSE AMARILLO
	ponerse_amarillo()
	
	# Efecto visual de activación
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 0.2, 0.2), 0.1)
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1)
	tween.set_loops(6)
	
	# Mostrar mensaje en pantalla
	if canvas_layer:
		var msg = Label.new()
		msg.text = "🔥 MODO OP ACTIVADO - Velocidad x3 🔥"
		msg.position = Vector2(300, 300)
		msg.add_theme_font_size_override("font_size", 28)
		msg.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
		canvas_layer.add_child(msg)
		await get_tree().create_timer(2.0).timeout
		msg.queue_free()

# ========== INPUT ==========

func _input(event):
	# ========================================================================
	#  MODO OP: Ctrl + Shift + O
	# ========================================================================
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_O and event.ctrl_pressed and event.shift_pressed:
			activar_modo_op()
	
	# ========================================================================
	#  RESTO DE INPUTS
	# ========================================================================
	if event.is_action_pressed("ui_cancel"):
		print("🔴 ESC PRESIONADO - Guardando partida...")
		Sistema_Guardado.guardar()
		get_tree().change_scene_to_file("res://escenas/Pausa.tscn")
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_I:
		if inventory_panel:
			inventory_panel.visible = !inventory_panel.visible
			if inventory_panel.visible:
				inventory_panel.actualizar_cartas(Sistema_Guardado.get_cartas())
