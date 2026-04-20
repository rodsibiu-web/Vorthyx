extends CanvasLayer

var puntos = 0
var animacion = true

func _ready():
	# Reducir FPS temporalmente
	Engine.max_fps = 10
	
	# Obtener tamaño de la pantalla
	var pantalla = get_viewport().get_visible_rect().size
	
	# Pantalla negra que cubre todo
	var rect = ColorRect.new()
	rect.color = Color.BLACK
	rect.size = pantalla
	add_child(rect)
	
	# Añadir texto "CARGANDO"
	var label = Label.new()
	label.text = "CARGANDO"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 50)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.size = pantalla
	add_child(label)
	
	# Iniciar animación de puntos
	animar_puntos(label)
	
	# Forzar varios frames
	for i in range(3):
		await get_tree().process_frame
	
	# Cargar partida
	Sistema_Guardado.cargar()
	
	# Esperar y terminar
	await get_tree().create_timer(2).timeout
	
	# Restaurar FPS y eliminar
	Engine.max_fps = 0
	queue_free()

func animar_puntos(label):
	while animacion and is_inside_tree():
		puntos = (puntos + 1) % 4
		label.text = "CARGANDO" + ".".repeat(puntos)
		await get_tree().create_timer(0.2).timeout
