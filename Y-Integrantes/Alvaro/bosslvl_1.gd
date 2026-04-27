extends CharacterBody2D

var vida = 300
var player = null
var velocidad = 80
var puede_atacar = true
var detectado = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea

func _ready():
	# Buscar al player
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemigos")
	
	# Conectar área de ataque
	if attack_area:
		attack_area.body_entered.connect(_on_attack_area_entered)
		attack_area.collision_mask = 1
	
	print("✅ BOSS listo")

func _physics_process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return
	
	var distancia = global_position.distance_to(player.global_position)
	
	# DETECTAR UNA SOLA VEZ
	if not detectado and distancia < 500:
		detectado = true
		print("🎯 BOSS detectado - ¡LO SEGUIRÁ PARA SIEMPRE!")
	
	# PERSECUCIÓN PERMANENTE UNA VEZ DETECTADO
	if detectado:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * velocidad
		move_and_slide()
		
		# Animaciones
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
	else:
		velocity = Vector2.ZERO
		move_and_slide()
		animated_sprite.play("idle")

func _on_attack_area_entered(body):
	if body == player and puede_atacar and detectado:
		atacar()

func atacar():
	puede_atacar = false
	print("⚔️ BOSS ataca!")
	
	# Animación de ataque
	var direction_to_player = (player.global_position - global_position).normalized()
	
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
	
	await get_tree().create_timer(0.3).timeout
	
	if player and player.has_method("recibir_dano"):
		player.recibir_dano(20)
	
	await get_tree().create_timer(0.5).timeout
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
	queue_free()
