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
		
		# === TU FOTO (IMAGEN) ===
		# Cambia "res://icon.svg" por la ruta de tu imagen
		var foto = TextureRect.new()
		var textura = load("res://icon.svg")  # <--- CAMBIA ESTA RUTA
		foto.texture = textura
		foto.set_anchors_preset(Control.PRESET_CENTER)
		foto.offset_left = -150
		foto.offset_top = -150
		foto.offset_right = 150
		foto.offset_bottom = 150
		foto.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		canvas.add_child(foto)
		
		# === BARRA ROJA BONITA ===
		# Fondo de la barra (gris oscuro)
		var barra_fondo = ColorRect.new()
		barra_fondo.color = Color(0.15, 0.15, 0.15, 1)
		barra_fondo.set_anchors_preset(Control.PRESET_CENTER)
		barra_fondo.offset_left = -300
		barra_fondo.offset_right = 300
		barra_fondo.offset_top = 130
		barra_fondo.offset_bottom = 155
		canvas.add_child(barra_fondo)
		
		# Borde de la barra (rojo)
		var barra_borde = ColorRect.new()
		barra_borde.color = Color(0.8, 0.1, 0.1, 1)
		barra_borde.set_anchors_preset(Control.PRESET_CENTER)
		barra_borde.offset_left = -305
		barra_borde.offset_right = 305
		barra_borde.offset_top = 125
		barra_borde.offset_bottom = 160
		canvas.add_child(barra_borde)
		
		# Barra de progreso (roja)
		var barra = ColorRect.new()
		barra.color = Color(0.95, 0.15, 0.15, 1)
		barra.set_anchors_preset(Control.PRESET_CENTER)
		barra.offset_left = -300
		barra.offset_right = -300
		barra.offset_top = 130
		barra.offset_bottom = 155
		canvas.add_child(barra)
		
		# Texto del porcentaje
		var porcentaje = Label.new()
		porcentaje.text = "0%"
		porcentaje.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		porcentaje.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		porcentaje.add_theme_font_size_override("font_size", 24)
		porcentaje.add_theme_color_override("font_color", Color.WHITE)
		porcentaje.set_anchors_preset(Control.PRESET_CENTER)
		porcentaje.offset_top = 185
		canvas.add_child(porcentaje)
		
		# Animación de la barra
		for i in range(0, 101, 5):
			var ancho = -300 + (600 * i / 100)
			barra.offset_right = ancho
			porcentaje.text = str(i) + "%"
			await get_tree().create_timer(0.05).timeout
		
		await get_tree().create_timer(0.3).timeout
		
		# === TELETRANSPORTAR A AMBOS JUGADORES EN POSICIONES SEPARADAS ===
		
		# Posición base
		var base_x = 7220
		var base_y = 4877
		
		# Separación entre jugadores (píxeles)
		var separacion =  -50
		
		# Determinar quién va a la izquierda y quién a la derecha
		if jugador1 and jugador2:
			# Comparar posiciones X actuales para mantener el orden
			if jugador1.position.x < jugador2.position.x:
				# Jugador 1 estaba más a la izquierda
				jugador1.position = Vector2(base_x, base_y)
				jugador2.position = Vector2(base_x + separacion, base_y)
				print("✅ Jugador1 (izquierda) a: ", base_x, ",", base_y)
				print("✅ Jugador2 (derecha) a: ", base_x + separacion, ",", base_y)
			else:
				# Jugador 2 estaba más a la izquierda
				jugador2.position = Vector2(base_x, base_y)
				jugador1.position = Vector2(base_x + separacion, base_y)
				print("✅ Jugador2 (izquierda) a: ", base_x, ",", base_y)
				print("✅ Jugador1 (derecha) a: ", base_x + separacion, ",", base_y)
		else:
			# Si solo hay un jugador, teletransportar solo a él
			if jugador1:
				jugador1.position = Vector2(base_x, base_y)
				print("✅ Solo Jugador1 a: ", base_x, ",", base_y)
			if jugador2:
				jugador2.position = Vector2(base_x, base_y)
				print("✅ Solo Jugador2 a: ", base_x, ",", base_y)
		
		# Limpiar pantalla de carga
		canvas.queue_free()
		
		print("✅ Ambos jugadores teletransportados en posiciones separadas")
