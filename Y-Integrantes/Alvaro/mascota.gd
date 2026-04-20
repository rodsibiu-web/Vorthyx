extends Node2D

var player = null
var offset_base = Vector2(-50, -30)
var suavizado = 8.0
var ultima_animacion = ""
var tiempo = 0
var lado_actual = -1
var flotacion_altura = 0
var escala_normal = Vector2(1, 1)

# Nuevas variables para la vuelta aleatoria
var dando_vuelta = false
var angulo_vuelta = 0
var velocidad_vuelta = 0
var tiempo_hasta_siguiente_vuelta = 0
var radio_vuelta = 70

@onready var animated_sprite = $AnimatedSprite2D
@onready var particles = $GPUParticles2D  # Opcional
@onready var audio_player = $AudioStreamPlayer2D  # Opcional

func _ready():
	player = get_tree().get_first_node_in_group("player")
	
	if animated_sprite:
		animated_sprite.play("idle")
		
		# Configurar partículas
		if particles:
			particles.emitting = true
		
		print("✅ Mascota lista con vueltas aleatorias!")
	
	# Inicializar tiempo aleatorio para primera vuelta
	tiempo_hasta_siguiente_vuelta = randf_range(5.0, 12.0)

func _physics_process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return
	
	# Verificar si debe empezar una vuelta aleatoria
	if not dando_vuelta:
		tiempo_hasta_siguiente_vuelta -= delta
		if tiempo_hasta_siguiente_vuelta <= 0:
			iniciar_vuelta_aleatoria()
	
	# Si está dando una vuelta
	if dando_vuelta:
		actualizar_vuelta(delta)
	else:
		# Comportamiento normal (lateral + flotación)
		comportamiento_normal(delta)

func iniciar_vuelta_aleatoria():
	dando_vuelta = true
	angulo_vuelta = 0
	# Velocidad aleatoria entre 2 y 5 radianes por segundo
	velocidad_vuelta = randf_range(2.5, 5.0)
	
	# Decidir dirección de la vuelta (aleatoria)
	var direccion_vuelta = 1 if randf() > 0.5 else -1
	velocidad_vuelta = velocidad_vuelta * direccion_vuelta
	
	# Efecto visual al empezar la vuelta
	if animated_sprite:
		animated_sprite.play("idle")
	
	# Pequeño salto al empezar la vuelta
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.1)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2)
	
	print("🔄 Mascota dando una vuelta!")

func actualizar_vuelta(delta):
	# Incrementar ángulo
	angulo_vuelta += velocidad_vuelta * delta
	
	# Calcular posición en círculo
	var offset_x = cos(angulo_vuelta) * radio_vuelta
	var offset_y = sin(angulo_vuelta) * radio_vuelta * 0.8
	
	# Flotación durante la vuelta
	flotacion_altura = sin(Time.get_ticks_msec() * 0.01) * 3
	
	# Posición final
	var posicion_deseada = player.global_position + Vector2(offset_x, offset_y + flotacion_altura)
	global_position = global_position.lerp(posicion_deseada, suavizado * delta)
	
	# Rotación según el ángulo
	rotation = angulo_vuelta * 0.5
	
	# Verificar si completó la vuelta (360 grados = 2*PI)
	if abs(angulo_vuelta) >= PI * 2:
		dando_vuelta = false
		# Esperar entre 3 y 10 segundos para la próxima vuelta
		tiempo_hasta_siguiente_vuelta = randf_range(3.0, 10.0)
		print("✅ Vuelta completada!")
		
		# Pequeña celebración al terminar
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
		tween.tween_property(self, "scale", Vector2(1, 1), 0.2)
		
		rotation = 0  # Resetear rotación

func comportamiento_normal(delta):
	# 1. Cambiar de lado cada 2 segundos
	tiempo += delta
	if tiempo > 2.0:
		tiempo = 0
		lado_actual = lado_actual * -1
		
		# Sonido al cambiar de lado (opcional)
		if audio_player and not audio_player.playing:
			audio_player.pitch_scale = randf_range(0.8, 1.2)
			audio_player.play()
	
	# 2. Offset dinámico con flotación
	var offset_dinamico = Vector2(60 * lado_actual, -30)
	
	# 3. Efecto de flotación
	flotacion_altura = sin(Time.get_ticks_msec() * 0.005) * 5
	
	# 4. Posición final
	var posicion_deseada = player.global_position + offset_dinamico + Vector2(0, flotacion_altura)
	global_position = global_position.lerp(posicion_deseada, suavizado * delta)
	
	# 5. Rotación suave según movimiento
	var direccion = player.velocity
	var rotacion_objetivo = 0.0
	if direccion.length() > 50:
		if direccion.x > 0:
			rotacion_objetivo = 0.15
		elif direccion.x < 0:
			rotacion_objetivo = -0.15
	rotation = lerp(rotation, rotacion_objetivo, 0.1)
	
	# 6. Animaciones
	if direccion.length() > 50:
		if abs(direccion.x) > abs(direccion.y):
			if direccion.x > 0:
				cambiar_animacion("derecha")
			else:
				cambiar_animacion("izquierda")
		else:
			if direccion.y > 0:
				cambiar_animacion("abajo")
			else:
				cambiar_animacion("arriba")
	else:
		cambiar_animacion("idle")
		
		# Efecto de "respiración" cuando está idle
		var escala = 1 + sin(Time.get_ticks_msec() * 0.003) * 0.03
		scale = Vector2(escala, escala)

func cambiar_animacion(nombre):
	if animated_sprite == null:
		return
	
	if ultima_animacion != nombre:
		if animated_sprite.sprite_frames.has_animation(nombre):
			animated_sprite.play(nombre)
			ultima_animacion = nombre

# Función para cuando el jugador recibe daño
func reaccionar_al_dano():
	# Efecto de susto
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.3, 0.7), 0.1)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2)
	
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(0.2).timeout
	modulate = Color(1, 1, 1)
