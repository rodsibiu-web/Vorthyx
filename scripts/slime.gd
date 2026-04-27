extends CharacterBody2D

var vida = 300
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
		print("🎯 BOSS detectó al jugador!")

func _physics_process(delta):
	if player == null:
		return
	
	if detectado:
		empuje = empuje.move_toward(Vector2.ZERO, 500 * delta)
		var direction = (player.global_position - global_position).normalized()
		velocity = empuje + (direction * 60)  # Un poco más lento que el slime normal
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
	
	# Animaciones de movimiento
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
	print("⚔️ BOSS ataca!")
	
	# Animación de ataque según dirección hacia el player
	var direction_to_player = (player.global_position - global_position).normalized()
	
	# Elegir animación de ataque según dirección
	if abs(direction_to_player.x) > abs(direction_to_player.y):
		if direction_to_player.x > 0:
			animated_sprite.play("atacar_derecha")
		else:
			animated_sprite.play("atacar_izquierda")
	else:
		if direction_to_player.y > 0:
			animated_sprite.play("atacar_abajo")
		else:
			animated_sprite.play("atacar_arriba")
	
	# Pequeña pausa para que coincida con la animación
	await get_tree().create_timer(0.3).timeout
	
	# Aplicar daño al player
	if player.has_method("recibir_dano"):
		player.recibir_dano(20)  # 2 corazones de daño
	
	# Esperar a que termine la animación
	await get_tree().create_timer(0.5).timeout
	
	# Volver a idle
	animated_sprite.play("idle")
	await get_tree().create_timer(0.8).timeout
	puede_atacar = true

func recibir_dano(cantidad):
	vida -= cantidad
	print("💚 BOSS vida: ", vida)
	
	modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	modulate = Color(1, 1, 1)
	
	if vida <= 0:
		morir()

func morir():
	print("💀 BOSS derrotado!")
	
	var global_node = get_node("/root/Node2D/VAR_ENEMIGOS")
	if global_node:
		global_node.boss_derrotado = true
		print("✅ BOSS eliminado!")
	
	queue_free()
