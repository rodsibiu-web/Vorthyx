extends Control



func _on_continuar_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/definitivo_lv1.tscn")

func _on_reload_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/definitivo_lv1.tscn")

func _on_salir_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/MenuPrincipal.tscn")
