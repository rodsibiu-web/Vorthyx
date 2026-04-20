extends Area2D

var experiencia = 50  # XP que da
var jugador = null
var recolectado = false

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func _ready():
	jugador = get_tree().get_first_node_in_group("player")
	body_entered.connect(_on_body_entered)
	
	# Animación de flotación
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(sprite, "position:y", sprite.position.y - 5, 0.5)
	tween.tween_property(sprite, "position:y", sprite.position.y, 0.5)

func _on_body_entered(body):
	if recolectado:
		return
	
	if body == jugador or body.is_in_group("player"):
		recolectado = true
		
		# LLAMAR DIRECTAMENTE A LA FUNCIÓN DEL JUGADOR
		jugador.ganar_experiencia(experiencia)
		print("🎯 Orbe tocó al jugador! +", experiencia, " XP")
		
		# Desaparecer
		queue_free()
