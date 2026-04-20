extends Control

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	print("💀 DERROTA - El jugador ha muerto")

func _on_nueva_partida_pressed() -> void:
	# Resetear todo el estado del juego
	Sistema_Guardado.nueva_partida()
	print("✨ Nueva partida desde pantalla de derrota")

func _on_salir_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/MenuPrincipal.tscn")
