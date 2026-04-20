extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "CharacterBody2D":
		body.position = Vector2(1000, 300)
		print("Cambió de habitación")
