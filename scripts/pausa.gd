extends Control

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_continuar_pressed():
	await get_tree().create_timer(0.05).timeout
	var carga = load("res://escenas/Carga.tscn").instantiate()
	get_tree().root.add_child(carga)
	queue_free()

func _on_new_game_pressed():
	# Nueva partida: resetea inventario, posiciones, vida y empieza nivel 1
	Sistema_Guardado.nueva_partida()
	print("✨ Nueva partida iniciada")

func _on_salir_pressed():
	get_tree().quit()
