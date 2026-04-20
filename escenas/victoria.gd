extends Control

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_nueva_partida_pressed() -> void:
	# Resetear todo el estado del juego
	Sistema_Guardado.nueva_partida()
	print("✨ Nueva partida desde pantalla de victoria")

func _on_salir_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/MenuPrincipal.tscn")
