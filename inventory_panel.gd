extends Panel

func _ready():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.85)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.8, 0.5, 0.2, 0.9)
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	add_theme_stylebox_override("panel", style)
	
	size = Vector2(500, 500)
	position = Vector2(50, -100)
	
	var titulo = Label.new()
	titulo.text = "📦 INVENTARIO"
	titulo.position = Vector2(130, 15)
	titulo.size = Vector2(200, 40)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 28)
	titulo.add_theme_color_override("font_color", Color(1, 0.8, 0.4))
	add_child(titulo)
	
	var btn = Button.new()
	btn.text = "✖ CERRAR"
	btn.position = Vector2(170, 450)
	btn.size = Vector2(150, 40)
	btn.add_theme_font_size_override("font_size", 18)
	btn.pressed.connect(_cerrar)
	add_child(btn)
	
	add_to_group("inventario_panel")
	visible = false
	print("✅ InventoryPanel listo")

func _cerrar():
	visible = false

func actualizar_cartas(cartas):
	print("Actualizando cartas: ", cartas.size())
	
	if has_node("CardsContainer"):
		$CardsContainer.queue_free()
		await get_tree().process_frame
	
	var scroll = ScrollContainer.new()
	scroll.name = "CardsContainer"
	scroll.position = Vector2(20, 80)
	scroll.size = Vector2(660, 390)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 25)
	scroll.add_child(hbox)
	
	for carta in cartas:
		var carta_frame = crear_carta_frame(carta)
		hbox.add_child(carta_frame)
	
	await get_tree().process_frame
	await get_tree().process_frame

func crear_carta_frame(carta):
	var carta_frame = Panel.new()
	carta_frame.size = Vector2(220, 150)
	carta_frame.add_theme_stylebox_override("panel", crear_estilo_carta())
	carta_frame.set_meta("carta_data", carta)
	
	var imagen = TextureRect.new()
	imagen.size = Vector2(80, 80)
	imagen.position = Vector2(15, 15)
	imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	if carta.has("ruta_imagen") and ResourceLoader.exists(carta["ruta_imagen"]):
		imagen.texture = load(carta["ruta_imagen"])
	else:
		var fallback = Label.new()
		fallback.text = "🃏"
		fallback.position = Vector2(35, 40)
		fallback.add_theme_font_size_override("font_size", 40)
		carta_frame.add_child(fallback)
	
	carta_frame.add_child(imagen)
	
	var nombre_label = Label.new()
	nombre_label.text = carta["tipo"]
	if carta.has("cantidad") and carta["cantidad"] > 1:
		nombre_label.text = carta["tipo"] + " x" + str(carta["cantidad"])
	nombre_label.position = Vector2(110, 25)
	nombre_label.size = Vector2(100, 30)
	nombre_label.add_theme_font_size_override("font_size", 16)
	nombre_label.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	nombre_label.visible = false
	carta_frame.add_child(nombre_label)
	carta_frame.set_meta("nombre_label", nombre_label)
	
	var valor_label = Label.new()
	valor_label.text = "+" + str(carta["valor"])
	valor_label.position = Vector2(110, 55)
	valor_label.size = Vector2(100, 30)
	valor_label.add_theme_font_size_override("font_size", 20)
	valor_label.add_theme_color_override("font_color", Color(0.4, 1, 0.4))
	valor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	valor_label.visible = false
	carta_frame.add_child(valor_label)
	carta_frame.set_meta("valor_label", valor_label)
	
	carta_frame.mouse_entered.connect(_on_carta_mouse_entered.bind(carta_frame, carta))
	carta_frame.mouse_exited.connect(_on_carta_mouse_exited.bind(carta_frame))
	
	return carta_frame

func _on_carta_mouse_entered(carta_frame, carta):
	# Guardar z_index original
	if not carta_frame.has_meta("original_z_index"):
		carta_frame.set_meta("original_z_index", carta_frame.z_index)
	
	# Crear tween para la animación de subida usando OFFSET
	var tween_up = create_tween()
	tween_up.tween_property(carta_frame, "offset", Vector2(0, -100), 0.1)
	
	# Animación de escala
	var tween_scale = create_tween()
	tween_scale.tween_property(carta_frame, "scale", Vector2(1.05, 1.05), 0.1)
	
	carta_frame.z_index = 10
	
	var nombre_label = carta_frame.get_meta("nombre_label")
	if nombre_label:
		nombre_label.visible = true
	
	var valor_label = carta_frame.get_meta("valor_label")
	if valor_label:
		valor_label.visible = true
	
	mostrar_tooltip(carta)

func _on_carta_mouse_exited(carta_frame):
	# Crear tween para la animación de bajada usando OFFSET
	var tween_down = create_tween()
	tween_down.tween_property(carta_frame, "offset", Vector2(0, 0), 0.1)
	
	# Animación de escala
	var tween_scale = create_tween()
	tween_scale.tween_property(carta_frame, "scale", Vector2(1, 1), 0.1)
	
	var original_z = carta_frame.get_meta("original_z_index", 0)
	carta_frame.z_index = original_z
	
	var nombre_label = carta_frame.get_meta("nombre_label")
	if nombre_label:
		nombre_label.visible = false
	
	var valor_label = carta_frame.get_meta("valor_label")
	if valor_label:
		valor_label.visible = false
	
	ocultar_tooltip()

func mostrar_tooltip(carta):
	ocultar_tooltip()
	
	var tooltip = Panel.new()
	tooltip.name = "Tooltip"
	tooltip.size = Vector2(260, 150)
	tooltip.position = Vector2(120, -170)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.95)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(1, 0.8, 0.4)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	tooltip.add_theme_stylebox_override("panel", style)
	
	var icono = ""
	match carta["tipo"]:
		"VIDA": icono = "❤️"
		"ESPADA": icono = "⚔️"
		"BOTA": icono = "👢"
		"FUEGO": icono = "🔥"
	
	var titulo = Label.new()
	titulo.text = icono + "  " + carta["tipo"]
	titulo.position = Vector2(10, 10)
	titulo.size = Vector2(240, 25)
	titulo.add_theme_font_size_override("font_size", 18)
	titulo.add_theme_color_override("font_color", Color(1, 0.8, 0.4))
	tooltip.add_child(titulo)
	
	var valor_label = Label.new()
	valor_label.text = "✦ VALOR: +" + str(carta["valor"])
	valor_label.position = Vector2(10, 40)
	valor_label.size = Vector2(240, 25)
	valor_label.add_theme_font_size_override("font_size", 14)
	valor_label.add_theme_color_override("font_color", Color(0.4, 1, 0.4))
	tooltip.add_child(valor_label)
	
	var cantidad_label = Label.new()
	cantidad_label.text = "✦ CANTIDAD: x" + str(carta.get("cantidad", 1))
	cantidad_label.position = Vector2(10, 65)
	cantidad_label.size = Vector2(240, 25)
	cantidad_label.add_theme_font_size_override("font_size", 14)
	cantidad_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	tooltip.add_child(cantidad_label)
	
	var efecto_texto = ""
	match carta["tipo"]:
		"VIDA":
			efecto_texto = "✨ Restaura " + str(carta["valor"]/10) + " corazones"
		"ESPADA":
			efecto_texto = "⚡ Aumenta daño en " + str(carta["valor"])
		"BOTA":
			efecto_texto = "💨 Aumenta velocidad en " + str(carta["valor"])
		"FUEGO":
			efecto_texto = "🔥 Mejora quemadura +" + str(carta["valor"])
	
	var efecto_label = Label.new()
	efecto_label.text = efecto_texto
	efecto_label.position = Vector2(10, 95)
	efecto_label.size = Vector2(240, 45)
	efecto_label.add_theme_font_size_override("font_size", 11)
	efecto_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
	efecto_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	tooltip.add_child(efecto_label)
	
	add_child(tooltip)

func ocultar_tooltip():
	if has_node("Tooltip"):
		$Tooltip.queue_free()

func crear_estilo_carta():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.1, 0.05, 0.95)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.8, 0.6, 0.3)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	return style

func _input(event):
	# Detectar la tecla I directamente
	if event is InputEventKey and event.pressed and event.keycode == KEY_I:
		visible = !visible
		if visible:
			actualizar_cartas(Sistema_Guardado.get_cartas())
			print("📦 Inventario abierto/cerrado con tecla I")
