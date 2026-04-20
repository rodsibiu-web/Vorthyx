extends Control

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	print("✅ Menú de pausa CARGADO")

func _on_continuar_pressed():
	print("🔵 HAS PRESIONADO CONTINUAR")
	get_tree().change_scene_to_file("res://escenas/definitivo_lv1.tscn")

func _on_new_game_pressed():
	print("🟢 HAS PRESIONADO NEW GAME")

func _on_salir_pressed():
	print("🔴 HAS PRESIONADO SALIR")
	get_tree().quit()
