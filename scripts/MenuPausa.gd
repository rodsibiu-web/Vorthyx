extends Node

func _physics_process(delta):
	if Input.is_action_pressed("pausa"):
		get_tree().change_scene_to_file("res://escenas/Pausa.tscn")
