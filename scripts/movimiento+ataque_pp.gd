extends CharacterBody2D

@export var speed = 300
@onready var anim = $AnimatedSprite2D

var atacando = false
var ultima_direccion = "abajo"

func _physics_process(delta):
	var direction = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	
	# Movimiento
	velocity = direction * speed
	move_and_slide()
	
	# Ataque con clic izquierdo
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not atacando:
		atacando = true
		velocity = Vector2.ZERO
		
		# Animación de ataque
		match ultima_direccion:
			"abajo":
				anim.play("ataque_abajo")
			"arriba":
				anim.play("ataque_arriba")
			"izq":
				anim.play("ataque_izq")
			"der":
				anim.play("ataque_der")
		
		await get_tree().create_timer(0.6).timeout
		atacando = false
	
	# Animaciones de movimiento
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
