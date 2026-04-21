extends StaticBody2D

var jugador_cerca = false
var abierto = false

@onready var anim = $AnimatedSprite2D
@onready var detection_zone = $Area2D

func _ready():
	if detection_zone:
		detection_zone.body_entered.connect(_on_body_entered)
		detection_zone.body_exited.connect(_on_body_exited)
	
	if anim:
		anim.stop()
		anim.frame = 0

func _on_body_entered(body):
	if body.name == "CharacterBody2D" and not abierto:
		jugador_cerca = true
		print("🎁 Presiona E")

func _on_body_exited(body):
	if body.name == "CharacterBody2D":
		jugador_cerca = false

func _process(delta):
	if not abierto and jugador_cerca and Input.is_action_just_pressed("abrir"):
		abrir()

func abrir():
	abierto = true
	print("🎁 Abriendo cofre...")
	
	if anim:
		anim.play("abrir")
		await anim.animation_finished
		anim.stop()
		anim.frame = 4  # Frame 4 = cofre abierto
	
	# Dar corazón
	var jugador = get_node("/root/Node2D/CharacterBody2D")
	if jugador and jugador.vida < jugador.max_vida:
		jugador.vida += 1
		jugador.actualizar_corazones()
		print("❤️ +1 corazón!")
	
	if detection_zone:
		detection_zone.queue_free()
