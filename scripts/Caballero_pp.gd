extends CharacterBody2D

@export var speed = 300
@onready var anim = $AnimatedSprite2D

var atacando = false
var ultima_direccion = "abajo"
var vida = 10
var max_vida = 10
var ataque_daño = 3
var hitbox = null
var corazones = []

func _ready():
	add_to_group("player")	

	
	# Resto de tu código...
	hitbox = $HitboxAtq
	if hitbox == null:
		hitbox = $Area2D
	if hitbox == null:
		hitbox = find_child("HitboxAtq", true, false)
	if hitbox == null:
		hitbox = find_child("Area2D", true, false)
	
	if hitbox:
		hitbox.visible = false
		hitbox.monitoring = false
		hitbox.body_entered.connect(_on_hitbox_entered)
	
	# Buscar corazones
	var heart_node = $heart
	if heart_node:
		for child in heart_node.get_children():
			if child is HBoxContainer or child is VBoxContainer:
				for corazon in child.get_children():
					if corazon is TextureRect:
						corazones.append(corazon)
	
	actualizar_corazones()
	print("Jugador iniciado con ", vida, " corazones")

func actualizar_corazones():
	for i in range(max_vida):
		if i < vida:
			corazones[i].modulate = Color(1, 1, 1)
		else:
			corazones[i].modulate = Color(0.2, 0.2, 0.2)

func _physics_process(delta):
	if Input.is_action_pressed("pausa"):
		get_tree().change_scene_to_file("res://escenas/Pausa.tscn")
		
	var direction = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	
	velocity = direction * speed
	move_and_slide()
	
	if Input.is_action_just_pressed("ataque") and not atacando:
		atacar()
		return
	
	if not atacando:
		if direction == Vector2.ZERO:
			anim.play("idle")
		else:
			if abs(direction.x) > abs(direction.y):
				if direction.x > 0:
					anim.play("der")
					ultima_direccion = "der"
				else:
					anim.play("izq")
					ultima_direccion = "izq"
			else:
				if direction.y > 0:
					anim.play("abajo")
					ultima_direccion = "abajo"
				else:
					anim.play("arriba")
					ultima_direccion = "arriba"

func atacar():
	if hitbox == null:
		return
	
	atacando = true
	velocity = Vector2.ZERO
	
	var mouse_pos = get_global_mouse_position()
	var player_pos = global_position
	var direccion = (mouse_pos - player_pos).normalized()
	
	if abs(direccion.x) > abs(direccion.y):
		if direccion.x > 0:
			hitbox.position = Vector2(25, 0)
			anim.play("ataque_der")
		else:
			hitbox.position = Vector2(-25, 0)
			anim.play("ataque_izq")
	else:
		if direccion.y > 0:
			hitbox.position = Vector2(0, 25)
			anim.play("ataque_abajo")
		else:
			hitbox.position = Vector2(0, -25)
			anim.play("ataque_arriba")
	
	hitbox.visible = true
	hitbox.monitoring = true
	
	await get_tree().create_timer(1).timeout
	
	hitbox.visible = false
	hitbox.monitoring = false
	atacando = false

func _on_hitbox_entered(body):
	if body.is_in_group("enemigos"):
		print("Golpe al enemigo!")
		if body.has_method("recibir_dano"):
			body.recibir_dano(ataque_daño * 10)

func recibir_dano(cantidad):
	var corazones_perdidos = cantidad / 10
	
	for i in range(corazones_perdidos):
		if vida > 0:
			vida -= 1
			actualizar_corazones()
			print("💔 Corazones: ", vida, "/", max_vida)
			await get_tree().create_timer(0.1).timeout
	
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.2).timeout
	modulate = Color(1, 1, 1)
	
	if vida <= 0:
		morir()

func morir():
	print("JUGADOR MUERTO")
	get_tree().change_scene_to_file("res://escenas/Derrota.tscn")
