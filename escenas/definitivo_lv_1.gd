extends Node2D

func _ready():
	# Esperar a que todo cargue
	await get_tree().process_frame
	
	# Buscar al segundo jugador de varias formas
	var segundo_jugador = null
	
	# Opción 1: Buscar por grupo
	var jugadores = get_tree().get_nodes_in_group("player2")
	if jugadores.size() > 0:
		segundo_jugador = jugadores[0]
		print("✅ Jugador 2 encontrado por grupo")
	
	# Opción 2: Buscar por nombre si no lo encontró
	if segundo_jugador == null:
		segundo_jugador = get_node_or_null("CharacterBody2D_")
		if segundo_jugador:
			print("✅ Jugador 2 encontrado como CharacterBody2D_")
	
	# Opción 3: Buscar por otro nombre
	if segundo_jugador == null:
		segundo_jugador = get_node_or_null("Personaje_secundario")
		if segundo_jugador:
			print("✅ Jugador 2 encontrado como Personaje_secundario")
	
	# Opción 4: Buscar cualquier nodo que tenga el script del jugador 2
	if segundo_jugador == null:
		for child in get_children():
			if child.has_method("is_in_group") and child.is_in_group("player2"):
				segundo_jugador = child
				print("✅ Jugador 2 encontrado por búsqueda: ", child.name)
	
	# Si lo encontró, ocultar o mostrar según el modo
	if segundo_jugador:
		if Sistema_Guardado.modo_2_jugadores:
			segundo_jugador.show()
			segundo_jugador.set_process(true)
			segundo_jugador.set_physics_process(true)
			
			# Activar hitbox del cuerpo
			var hitbox_cuerpo = segundo_jugador.get_node_or_null("CollisionShape2D_")
			if hitbox_cuerpo:
				hitbox_cuerpo.disabled = false
				print("✅ Hitbox del cuerpo activada")
			
			# Activar hitbox de ataque
			var hitbox_ataque = segundo_jugador.get_node_or_null("HitboxAtq_")
			if hitbox_ataque:
				hitbox_ataque.monitoring = true
				print("✅ Hitbox de ataque activada")
			
			# Mostrar también los corazones
			var corazones = segundo_jugador.get_node_or_null("heart")
			if corazones:
				corazones.visible = true
			
			print("👥 Modo 2 jugadores - Segundo jugador VISIBLE")
		else:
			segundo_jugador.hide()
			segundo_jugador.set_process(false)
			segundo_jugador.set_physics_process(false)
			
			# Desactivar hitbox del cuerpo
			var hitbox_cuerpo = segundo_jugador.get_node_or_null("CollisionShape2D_")
			if hitbox_cuerpo:
				hitbox_cuerpo.disabled = true
				print("🚫 Hitbox del cuerpo desactivada")
			
			# Desactivar hitbox de ataque
			var hitbox_ataque = segundo_jugador.get_node_or_null("HitboxAtq_")
			if hitbox_ataque:
				hitbox_ataque.monitoring = false
				hitbox_ataque.visible = false
				print("🚫 Hitbox de ataque desactivada")
			
			# Ocultar también los CORAZONES del jugador 2
			var corazones = segundo_jugador.get_node_or_null("heart")
			if corazones:
				corazones.visible = false
				print("❤️ Corazones del jugador 2 ocultos")
			
			print("🎮 Modo 1 jugador - Segundo jugador OCULTO")
	else:
		print("❌ No se encontró el segundo jugador en la escena")
	
	# Mostrar el estado actual
	print("🔍 Sistema_Guardado.modo_2_jugadores = ", Sistema_Guardado.modo_2_jugadores)
