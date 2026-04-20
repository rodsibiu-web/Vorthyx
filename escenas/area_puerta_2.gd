extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Verificar si el cuerpo es el jugador 1 o el jugador 2
	if body.is_in_group("player") or body.is_in_group("player2"):
		# Buscar ambos jugadores
		var jugador1 = get_tree().get_first_node_in_group("player")
		var jugador2 = get_tree().get_first_node_in_group("player2")
		
		# Crear capa
		var canvas = CanvasLayer.new()
		add_child(canvas)
		
		# Fondo negro
		var fondo = ColorRect.new()
		fondo.color = Color.BLACK
		fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
		canvas.add_child(fondo)
		
		# ====================================================================
		# TEXTO "NIVEL 2" GRANDE
		# ====================================================================
		var texto_nivel = Label.new()
		texto_nivel.text = "NIVEL 2"
		texto_nivel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		texto_nivel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		texto_nivel.add_theme_font_size_override("font_size", 48)
		texto_nivel.add_theme_color_override("font_color", Color(1, 0.8, 0.3))
		texto_nivel.set_anchors_preset(Control.PRESET_CENTER)
		texto_nivel.offset_top = -150
		canvas.add_child(texto_nivel)
		
		# ====================================================================
		# TEXTO "CARGANDO..." DEBAJO
		# ====================================================================
		var texto_cargando = Label.new()
		texto_cargando.text = "CARGANDO..."
		texto_cargando.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		texto_cargando.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		texto_cargando.add_theme_font_size_override("font_size", 24)
		texto_cargando.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		texto_cargando.set_anchors_preset(Control.PRESET_CENTER)
		texto_cargando.offset_top = -80
		canvas.add_child(texto_cargando)
		
		# ====================================================================
		# BARRA DE CARGA
		# ====================================================================
		# Fondo de la barra (gris oscuro)
		var barra_fondo = ColorRect.new()
		barra_fondo.color = Color(0.15, 0.15, 0.15, 1)
		barra_fondo.set_anchors_preset(Control.PRESET_CENTER)
		barra_fondo.offset_left = -300
		barra_fondo.offset_right = 300
		barra_fondo.offset_top = 30
		barra_fondo.offset_bottom = 55
		canvas.add_child(barra_fondo)
		
		# Borde de la barra (dorado)
		var barra_borde = ColorRect.new()
		barra_borde.color = Color(0.9, 0.7, 0.2, 1)
		barra_borde.set_anchors_preset(Control.PRESET_CENTER)
		barra_borde.offset_left = -305
		barra_borde.offset_right = 305
		barra_borde.offset_top = 25
		barra_borde.offset_bottom = 60
		canvas.add_child(barra_borde)
		
		# Barra de progreso (roja)
		var barra = ColorRect.new()
		barra.color = Color(0.95, 0.3, 0.2, 1)
		barra.set_anchors_preset(Control.PRESET_CENTER)
		barra.offset_left = -300
		barra.offset_right = -300
		barra.offset_top = 30
		barra.offset_bottom = 55
		canvas.add_child(barra)
		
		# Texto del porcentaje
		var porcentaje = Label.new()
		porcentaje.text = "0%"
		porcentaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		porcentaje.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		porcentaje.add_theme_font_size_override("font_size", 20)
		porcentaje.add_theme_color_override("font_color", Color.WHITE)
		porcentaje.set_anchors_preset(Control.PRESET_CENTER)
		porcentaje.offset_top = 85
		canvas.add_child(porcentaje)
		
		# ====================================================================
		# ANIMACIÓN DE LA BARRA
		# ====================================================================
		for i in range(0, 101, 5):
			var ancho = -300 + (600 * i / 100)
			barra.offset_right = ancho
			porcentaje.text = str(i) + "%"
			await get_tree().create_timer(0.05).timeout
		
		await get_tree().create_timer(0.3).timeout
		
		# ====================================================================
		# TELETRANSPORTAR A AMBOS JUGADORES
		# ====================================================================
		var nueva_pos_x = 1387
		var nueva_pos_y = 4877
		
		if jugador1:
			jugador1.position = Vector2(nueva_pos_x, nueva_pos_y)
			print("✅ Jugador 1 teletransportado a: ", nueva_pos_x, ",", nueva_pos_y)
		else:
			print("⚠️ Jugador 1 no encontrado")
		
		if jugador2:
			jugador2.position = Vector2(nueva_pos_x, nueva_pos_y)
			print("✅ Jugador 2 teletransportado a: ", nueva_pos_x, ",", nueva_pos_y)
		else:
			print("⚠️ Jugador 2 no encontrado")
		
		# Limpiar pantalla de carga
		canvas.queue_free()
		
		print("✅ Ambos jugadores teletransportados al NIVEL 2")
