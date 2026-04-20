extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "CharacterBody2D":
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
		
		# Teletransportar
		body.position = Vector2(70, 300)
		
		# Limpiar
		canvas.queue_free()
		
		print("✅ Teletransportado")
