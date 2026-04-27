extends CharacterBody2D

var vida = 100
var player = null
var empuje = Vector2.ZERO
var puede_atacar = true
var detectado = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea

func _ready():
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemigos")
	
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_entered)
	
	if attack_area:
		attack_area.body_entered.connect(_on_attack_area_entered)
		attack_area.collision_mask = 1

func _on_detection_area_entered(body):
	if body == player:
		detectado = true

func _physics_process(delta):
	if player == null:
		return
	
	if detectado:
		empuje = empuje.move_toward(Vector2.ZERO, 500 * delta)
		var direction = (player.global_position - global_position).normalized()
		velocity = empuje + (direction * 80)
		move_and_slide()
		
		for i in get_slide_collision_count():
			var colision = get_slide_collision(i)
			if colision.get_collider() == player:
				var normal = colision.get_normal()
				empuje = normal * 400
				position += normal * 10
	else:
		velocity = Vector2.ZERO
		move_and_slide()
	
	if velocity.length() > 5:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0:
				animated_sprite.play("derecha")
			else:
				animated_sprite.play("izquierda")
		else:
			if velocity.y > 0:
				animated_sprite.play("abajo")
			else:
				animated_sprite.play("arriba")
	else:
		animated_sprite.play("idle")

func _on_attack_area_entered(body):
	if body == player and puede_atacar and detectado:
		atacar()

func atacar():
	puede_atacar = false
	print("⚔️ Slime ataca!")
	
	if player.has_method("recibir_dano"):
		player.recibir_dano(10)  # 1 corazón de daño
	
	await get_tree().create_timer(1.0).timeout
	puede_atacar = true
func recibir_dano(cantidad):
	vida -= cantidad
	print("❤️ Slime vida: ", vida)
	
	modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	modulate = Color(1, 1, 1)
	
	if vida <= 0:
		morir()

func morir():
	print("💀 Slime muerto")
	
	var global_node = get_node("/root/Node2D/VAR_ENEMIGOS")
	if global_node:
		global_node.slimes_muertos += 1
		print("Slimes muertos totales: ", global_node.slimes_muertos, "/3")
	
	queue_free()
