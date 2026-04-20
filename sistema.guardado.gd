extends Node

# ========== MODO DE JUEGO ==========
var modo_2_jugadores = false

# ========== DATOS DEL JUGADOR 1 ==========
var pos_x = 0
var pos_y = 0
var vida = 10

# ========== DATOS DEL JUGADOR 2 ==========
var pos_x2 = 0
var pos_y2 = 0
var vida2 = 10

# ========== DATOS DE LA PARTIDA ==========
var escena = ""
var slimes_muertos = 0
var cofre_abierto = false

# ========== INVENTARIO COMPARTIDO ==========
var cartas_recogidas = []

# ========== FUNCIONES DEL INVENTARIO ==========

func get_cartas():
	return cartas_recogidas

func añadir_carta(tipo, valor, ruta_imagen):
	# Buscar si ya existe esa carta
	for carta in cartas_recogidas:
		if carta["tipo"] == tipo:
			carta["valor"] += valor
			carta["cantidad"] += 1
			print("📦 Acumulado: ", tipo, " +", valor, " (Total: ", carta["valor"], " x", carta["cantidad"], ")")
			aplicar_efecto_carta(tipo, valor)
			return
	
	# Nueva carta
	cartas_recogidas.append({
		"tipo": tipo,
		"valor": valor,
		"cantidad": 1,
		"ruta_imagen": ruta_imagen
	})
	print("🃏 Nueva carta: ", tipo, " +", valor)
	aplicar_efecto_carta(tipo, valor)

func aplicar_efecto_carta(tipo, valor):
	var jugador1 = get_tree().get_first_node_in_group("player")
	var jugador2 = get_tree().get_first_node_in_group("player2")
	
	match tipo:
		"VIDA":
			if jugador1 and jugador1.has_method("curar"):
				jugador1.curar(valor)
			if jugador2 and jugador2.has_method("curar"):
				jugador2.curar(valor)
			print("❤️ +", valor, " de vida para ambos jugadores")
		
		"ESPADA":
			if jugador1 and jugador1.has_method("aumentar_dano"):
				jugador1.aumentar_dano(valor)
			if jugador2 and jugador2.has_method("aumentar_dano"):
				jugador2.aumentar_dano(valor)
			print("⚔️ +", valor, " de daño para ambos jugadores")
		
		"BOTA":
			if jugador1 and jugador1.has_method("aumentar_velocidad"):
				jugador1.aumentar_velocidad(valor)
			if jugador2 and jugador2.has_method("aumentar_velocidad"):
				jugador2.aumentar_velocidad(valor)
			print("👢 +", valor, " de velocidad para ambos jugadores")
		
		"FUEGO":
			if jugador1 and jugador1.has_method("mejorar_quemadura"):
				jugador1.mejorar_quemadura(valor, 0)
			if jugador2 and jugador2.has_method("mejorar_quemadura"):
				jugador2.mejorar_quemadura(valor, 0)
			print("🔥 +", valor, " de daño de fuego para ambos jugadores")

func limpiar_inventario():
	cartas_recogidas = []

# ========== FUNCIONES DE GUARDADO ==========

func guardar():
	print("💾 GUARDANDO...")
	
	# Guardar jugador 1
	var jugador = get_tree().get_first_node_in_group("player")
	if jugador:
		pos_x = jugador.global_position.x
		pos_y = jugador.global_position.y
		vida = jugador.vida
		print("  Jugador 1 - Pos: (", pos_x, ",", pos_y, ") Vida: ", vida)
	
	# Guardar jugador 2
	var jugador2 = get_tree().get_first_node_in_group("player2")
	if jugador2:
		pos_x2 = jugador2.global_position.x
		pos_y2 = jugador2.global_position.y
		vida2 = jugador2.vida
		print("  Jugador 2 - Pos: (", pos_x2, ",", pos_y2, ") Vida: ", vida2)
	
	# Guardar escena
	escena = get_tree().current_scene.scene_file_path
	print("  Escena: ", escena)
	
	# Guardar slimes (contador)
	var contador = get_tree().get_first_node_in_group("contador")
	if contador:
		slimes_muertos = contador.slimes_muertos
		print("  Slimes muertos: ", slimes_muertos)
	
	# Guardar cofre
	var cofre = get_tree().get_first_node_in_group("cofres")
	if cofre:
		cofre_abierto = cofre.abierto
		print("  Cofre abierto: ", cofre_abierto)
	
	# Guardar inventario de cartas
	# (Las cartas ya están en cartas_recogidas)
	print("  Cartas guardadas: ", cartas_recogidas.size())
	
	print("✅ GUARDADO COMPLETADO")

func cargar():
	if escena == "":
		print("❌ No hay partida")
		return
	
	# Mostrar pantalla de carga
	mostrar_pantalla_carga()
	
	# Cambiar de escena
	get_tree().change_scene_to_file(escena)
	
	# Esperar a que cargue
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	# Restaurar jugador 1
	var jugador = get_tree().get_first_node_in_group("player")
	if jugador:
		jugador.global_position = Vector2(pos_x, pos_y)
		jugador.vida = vida
		if jugador.has_method("actualizar_corazones"):
			jugador.actualizar_corazones()
		print("✅ Jugador 1 restaurado - Vida: ", vida)
	
	# Restaurar jugador 2
	var jugador2 = get_tree().get_first_node_in_group("player2")
	if jugador2:
		jugador2.global_position = Vector2(pos_x2, pos_y2)
		jugador2.vida = vida2
		if jugador2.has_method("actualizar_corazones"):
			jugador2.actualizar_corazones()
		print("✅ Jugador 2 restaurado - Vida: ", vida2)
	
	# Restaurar slimes
	var contador = get_tree().get_first_node_in_group("contador")
	if contador:
		contador.slimes_muertos = slimes_muertos
		var todos_slimes = get_tree().get_nodes_in_group("enemigos")
		var a_eliminar = slimes_muertos
		for slime in todos_slimes:
			if a_eliminar > 0:
				slime.queue_free()
				a_eliminar -= 1
	
	# Restaurar cofre
	var cofre = get_tree().get_first_node_in_group("cofres")
	if cofre and cofre_abierto:
		cofre.abierto = true
		if cofre.has_node("AnimatedSprite2D"):
			cofre.get_node("AnimatedSprite2D").frame = 4
	
	# Restaurar efectos de cartas a los jugadores
	aplicar_efectos_acumulados()
	
	# Ocultar pantalla de carga
	await get_tree().create_timer(0.5).timeout
	ocultar_pantalla_carga()

func aplicar_efectos_acumulados():
	var jugador1 = get_tree().get_first_node_in_group("player")
	var jugador2 = get_tree().get_first_node_in_group("player2")
	
	for carta in cartas_recogidas:
		match carta["tipo"]:
			"ESPADA":
				if jugador1 and jugador1.has_method("aumentar_dano"):
					jugador1.aumentar_dano(carta["valor"])
				if jugador2 and jugador2.has_method("aumentar_dano"):
					jugador2.aumentar_dano(carta["valor"])
			"BOTA":
				if jugador1 and jugador1.has_method("aumentar_velocidad"):
					jugador1.aumentar_velocidad(carta["valor"])
				if jugador2 and jugador2.has_method("aumentar_velocidad"):
					jugador2.aumentar_velocidad(carta["valor"])
			"FUEGO":
				if jugador1 and jugador1.has_method("mejorar_quemadura"):
					jugador1.mejorar_quemadura(carta["valor"], 0)
				if jugador2 and jugador2.has_method("mejorar_quemadura"):
					jugador2.mejorar_quemadura(carta["valor"], 0)

func mostrar_pantalla_carga():
	var pantalla = ColorRect.new()
	pantalla.name = "PantallaCarga"
	pantalla.color = Color(0, 0, 0, 1)
	pantalla.size = Vector2(1920, 1080)
	
	var label = Label.new()
	label.text = "CARGANDO..."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 50)
	label.add_theme_color_override("font_color", Color.WHITE)
	pantalla.add_child(label)
	
	get_tree().root.add_child(pantalla)

func ocultar_pantalla_carga():
	var pantalla = get_tree().root.get_node_or_null("PantallaCarga")
	if pantalla:
		pantalla.queue_free()

func nueva_partida():
	print("🆕 NUEVA PARTIDA")
	escena = ""
	slimes_muertos = 0
	cofre_abierto = false
	
	# Resetear variables de jugadores
	pos_x = 0
	pos_y = 0
	vida = 10
	pos_x2 = 0
	pos_y2 = 0
	vida2 = 10
	
	# Resetear inventario
	cartas_recogidas = []
	
	var contador = get_tree().get_first_node_in_group("contador")
	if contador:
		contador.slimes_muertos = 0
	
	get_tree().change_scene_to_file("res://escenas/definitivo_lv1.tscn")
