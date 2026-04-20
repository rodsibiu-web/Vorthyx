extends Control

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Conectar botones (ajusta según los nombres de tus botones)
	# Si se llaman "Button" y "Button2" como en tu captura anterior:
	$TextureRect/Button.pressed.connect(_on_1_jugador_pressed)
	$TextureRect/Button2.pressed.connect(_on_2_jugadores_pressed)
	
	print("✅ Selección de modo cargada")

func _on_1_jugador_pressed():
	print("🎮 Modo 1 Jugador seleccionado")
	Sistema_Guardado.modo_2_jugadores = false
	get_tree().change_scene_to_file("res://escenas/definitivo_lv1.tscn")

func _on_2_jugadores_pressed():
	print("👥 Modo 2 Jugadores seleccionado")
	Sistema_Guardado.modo_2_jugadores = true
	get_tree().change_scene_to_file("res://escenas/definitivo_lv1.tscn")
