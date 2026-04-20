extends Control

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Conectar botones (usando los nombres exactos)
	$VBoxContainer/jugar.pressed.connect(_on_jugar_pressed)
	$VBoxContainer/salir.pressed.connect(_on_salir_pressed)
	
	print("✅ Menú principal cargado - Botones conectados")

func _on_jugar_pressed():
	print("🎮 JUGAR presionado - Nueva partida")
	
	# ========================================================================
	#  RESETEAR INVENTARIO ANTES DE EMPEZAR NUEVA PARTIDA
	# ========================================================================
	Sistema_Guardado.limpiar_inventario()
	print("🗑️ Inventario reseteado")
	
	# Ir a la pantalla de selección de 1 o 2 jugadores
	get_tree().change_scene_to_file("res://escenas/menu_JUGADORES( 1- 2 ).tscn")

func _on_salir_pressed():
	print("👋 SALIR presionado - Cerrando juego")
	get_tree().quit()
