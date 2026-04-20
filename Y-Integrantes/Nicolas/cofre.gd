extends StaticBody2D

var jugador_cerca = null
var abierto = false
var jugador_que_abrio = null

@onready var anim = $AnimatedSprite2D
@onready var detection_zone = $Area2D

# Lista de posibles cartas (puedes añadir más)
var cartas_posibles = [
	{"tipo": "VIDA", "valor": 20, "ruta": "res://Y-Integrantes/Iker/carta heal.png"},
	{"tipo": "ESPADA", "valor": 5, "ruta": "res://Y-Integrantes/Iker/carta ataque.png"},
	{"tipo": "BOTA", "valor": 50, "ruta": "res://Y-Integrantes/Iker/carta speed.png"},
	{"tipo": "FUEGO", "valor": 5, "ruta": "res://Y-Integrantes/Iker/carta fuego.png"}
]

func _ready():
	add_to_group("cofres")
	
	if detection_zone:
		detection_zone.body_entered.connect(_on_body_entered)
		detection_zone.body_exited.connect(_on_body_exited)
	
	if anim:
		anim.stop()
		anim.frame = 0
	
	if abierto:
		anim.frame = 4
		if detection_zone:
			detection_zone.queue_free()

func _on_body_entered(body):
	if (body.is_in_group("player") or body.is_in_group("player2")) and not abierto:
		jugador_cerca = body
		print("🎁 ", body.name, " cerca - Presiona E")

func _on_body_exited(body):
	if body == jugador_cerca and not abierto:
		jugador_cerca = null

func _process(delta):
	if not abierto and jugador_cerca != null:
		if Input.is_action_just_pressed("abrir"):
			abrir()

func abrir():
	if abierto:
		return
	
	abierto = true
	jugador_que_abrio = jugador_cerca
	print("🎁 Abriendo cofre...")
	
	if anim:
		anim.play("abrir")
		await anim.animation_finished
		anim.stop()
		anim.frame = 4
	
	# Entregar carta aleatoria
	if jugador_que_abrio != null:
		# Elegir carta aleatoria
		var carta_elegida = cartas_posibles[randi() % cartas_posibles.size()]
		
		print("✨ El cofre ha dado: ", carta_elegida["tipo"], " +", carta_elegida["valor"])
		
		# Buscar ambos jugadores
		var jugador1 = get_tree().get_first_node_in_group("player")
		var jugador2 = get_tree().get_first_node_in_group("player2")
		
		# === APLICAR EFECTO A AMBOS JUGADORES ===
		match carta_elegida["tipo"]:
			"VIDA":
				if jugador1 and jugador1.has_method("curar"):
					jugador1.curar(carta_elegida["valor"])
				if jugador2 and jugador2.has_method("curar"):
					jugador2.curar(carta_elegida["valor"])
				print("❤️ Ambos jugadores han recibido +", carta_elegida["valor"], " de vida")
			
			"ESPADA":
				if jugador1 and jugador1.has_method("aumentar_dano"):
					jugador1.aumentar_dano(carta_elegida["valor"])
				if jugador2 and jugador2.has_method("aumentar_dano"):
					jugador2.aumentar_dano(carta_elegida["valor"])
				print("⚔️ Ambos jugadores han recibido +", carta_elegida["valor"], " de daño")
			
			"BOTA":
				if jugador1 and jugador1.has_method("aumentar_velocidad"):
					jugador1.aumentar_velocidad(carta_elegida["valor"])
				if jugador2 and jugador2.has_method("aumentar_velocidad"):
					jugador2.aumentar_velocidad(carta_elegida["valor"])
				print("👢 Ambos jugadores han recibido +", carta_elegida["valor"], " de velocidad")
			
			"FUEGO":
				if jugador1 and jugador1.has_method("mejorar_quemadura"):
					jugador1.mejorar_quemadura(5, 10)
				if jugador2 and jugador2.has_method("mejorar_quemadura"):
					jugador2.mejorar_quemadura(5, 10)
				print("🔥 Ambos jugadores han mejorado su quemadura")
		
		# === AÑADIR CARTA AL INVENTARIO COMPARTIDO ===
		Sistema_Guardado.añadir_carta(carta_elegida["tipo"], carta_elegida["valor"], carta_elegida["ruta"])
		
		# === ACTUALIZAR INVENTARIO SI ESTÁ ABIERTO ===
		actualizar_inventario_si_visible()
		
		print("🎁 ", jugador_que_abrio.name, " ha abierto el cofre y ambos reciben la carta!")
	else:
		print("❌ No hay jugador para dar la carta")
	
	if detection_zone:
		detection_zone.queue_free()

func actualizar_inventario_si_visible():
	var panel = get_tree().get_first_node_in_group("inventario_panel")
	if panel and panel.visible:
		panel.actualizar_cartas(Sistema_Guardado.get_cartas())
		print("🔄 Inventario actualizado")

func marcar_como_abierto():
	if abierto:
		return
	abierto = true
	if anim:
		anim.stop()
		anim.frame = 4
	if detection_zone:
		detection_zone.queue_free()

func esta_abierto():
	return abierto
