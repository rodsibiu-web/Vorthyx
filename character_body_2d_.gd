extends CharacterBody2D

@export var speed = 300.0

@onready var anim = $AnimatedSprite2D_
@onready var camera = $Camera2D

var inventory_panel = null
var atacando = false
var ultima_direccion = "abajo"
var vida = 10
var max_vida = 10
var ataque_daño = 3
var hitbox = null
var corazones = []

# ========== SISTEMA DE QUEMADURA ==========
var daño_quemadura = 0
var duracion_quemadura = 0

func cargar_inventario_ui():
	inventory_panel = get_tree().get_first_node_in_group("inventario_panel")
	if not inventory_panel:
		var panel_scene = preload("res://escenas/InventoryPanel.tscn")
		if panel_scene:
			inventory_panel = panel_scene.instantiate()
			get_tree().root.add_child(inventory_panel)
			print("✅ Panel de inventario compartido creado")

func _ready():
	cargar_inventario_ui()
	add_to_group("player2")
	
	if camera:
		camera.enabled = true
		camera.position_smoothing_enabled = true
	
	# Configurar hitbox de ataque
	hitbox = $HitboxAtq_
	if hitbox == null:
		hitbox = $Area2D
	if hitbox == null:
		hitbox = find_child("HitboxAtq_", true, false)
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
	aplicar_efectos_acumulados()
	print("✅ Jugador 2 iniciado")

func aplicar_efectos_acumulados():
	var cartas = Sistema_Guardado.get_cartas()
	for carta in cartas:
		match carta["tipo"]:
			"ESPADA":
				ataque_daño += carta["valor"]
			"BOTA":
				speed += carta["valor"]
			"FUEGO":
				daño_quemadura += carta["valor"]

func actualizar_corazones():
	for i in range(max_vida):
		if i < corazones.size():
			if i < vida:
				corazones[i].modulate = Color(1, 1, 1)
			else:
				corazones[i].modulate = Color(0.2, 0.2, 0.2)

func _physics_process(delta):
	var direction = Input.get_vector("izquierda_2", "derecha_2", "arriba_2", "abajo_2")
	
	if direction.length() > 1.0:
		direction = direction.normalized()
	
	velocity = direction * speed
	move_and_slide()
	
	if Input.is_action_just_pressed("Ataque_2") and not atacando:
		atacar()
		return
	
	if not atacando:
		actualizar_animaciones(direction)

func actualizar_animaciones(direction: Vector2):
	if direction == Vector2.ZERO:
		anim.play("idle")
		return
	
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
	
	modulate = Color(1.5, 1.2, 1.2)
	await get_tree().create_timer(0.05).timeout
	modulate = Color(1, 1, 1)
	
	match ultima_direccion:
		"der":
			hitbox.position = Vector2(25, 0)
			anim.play("ataque_der")
		"izq":
			hitbox.position = Vector2(-25, 0)
			anim.play("ataque_izq")
		"abajo":
			hitbox.position = Vector2(0, 25)
			anim.play("ataque_abajo")
		"arriba":
			hitbox.position = Vector2(0, -25)
			anim.play("ataque_arriba")
	
	hitbox.visible = true
	hitbox.monitoring = true
	
	await get_tree().create_timer(0.8).timeout
	
	hitbox.visible = false
	hitbox.monitoring = false
	atacando = false

func _on_hitbox_entered(body):
	if body.is_in_group("enemigos"):
		print("⚔️ Jugador 2 golpea al enemigo!")
		if body.has_method("recibir_dano"):
			body.recibir_dano(ataque_daño * 10)
		if daño_quemadura > 0 and body.has_method("aplicar_quemadura"):
			body.aplicar_quemadura(daño_quemadura, duracion_quemadura)

func recibir_dano(cantidad):
	var corazones_perdidos = cantidad / 10
	
	for i in range(corazones_perdidos):
		if vida > 0:
			vida -= 1
			actualizar_corazones()
			print("💔 Jugador 2 - Corazones: ", vida, "/", max_vida)
			await get_tree().create_timer(0.1).timeout
	
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.2).timeout
	modulate = Color(1, 1, 1)
	
	if vida <= 0:
		morir()

func morir():
	print("💀 JUGADOR 2 MUERTO")
	queue_free()

# ========== FUNCIONES PARA EFECTOS DE CARTAS ==========

func curar(cantidad):
	var curacion = cantidad / 10
	vida += curacion
	if vida > max_vida:
		vida = max_vida
	actualizar_corazones()
	print("❤️ Jugador 2 curado +", curacion)

func aumentar_dano(cantidad):
	ataque_daño += cantidad
	print("⚔️ Jugador 2 - Daño aumentado +", cantidad)

func aumentar_velocidad(cantidad):
	speed += cantidad
	print("👢 Jugador 2 - Velocidad aumentada +", cantidad)

func mejorar_quemadura(incremento_daño, incremento_duracion):
	daño_quemadura += incremento_daño
	duracion_quemadura += incremento_duracion
	print("🔥 Jugador 2 - Quemadura mejorada")

func _input(event):
	if event.is_action_pressed("inventario"):
		if inventory_panel:
			inventory_panel.visible = !inventory_panel.visible
			if inventory_panel.visible:
				inventory_panel.actualizar_cartas(Sistema_Guardado.get_cartas())
