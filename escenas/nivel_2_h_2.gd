extends Node2D

# ============================================================================
#  GESTOR DE PUERTAS - DETECTA CUANDO MUEREN LOS ENEMIGOS Y ABRE EL PASO
# ============================================================================

# Configuración: número de enemigos que hay en esta habitación
@export var enemigos_necesarios = 4  # Cambia según la habitación (3 o 4)

# Variables internas
var enemigos_restantes = 0
var paso_abierto = false

func _ready():
	# Esperar un frame para que todos los enemigos se registren
	await get_tree().process_frame
	# Contar los enemigos en la escena
	contar_enemigos()
	print("✅ Gestor iniciado. Enemigos en esta habitación: ", enemigos_restantes)

func contar_enemigos():
	# Buscar todos los enemigos en la escena (grupo "enemigos")
	var todos_los_enemigos = get_tree().get_nodes_in_group("enemigos")
	enemigos_restantes = todos_los_enemigos.size()
	# Conectar la señal de muerte de cada enemigo
	for enemigo in todos_los_enemigos:
		if enemigo.has_signal("murio"):
			enemigo.murio.connect(_on_enemigo_muerto)
		else:
			# Si el enemigo no tiene señal, podemos usar un grupo o verificar cada frame
			# Alternativa: usar un grupo "enemigos" y verificar cada frame
			pass
	print("📊 Enemigos encontrados: ", enemigos_restantes)

func _on_enemigo_muerto():
	enemigos_restantes -= 1
	print("💀 Enemigo muerto. Restantes: ", enemigos_restantes, "/", enemigos_necesarios)
	if enemigos_restantes <= 0 and not paso_abierto:
		abrir_paso()

# Método alternativo: verificar cada frame (más simple y no necesita señales)
func _process(delta):
	if paso_abierto:
		return
	# Contar enemigos vivos en tiempo real
	var vivos = 0
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		if is_instance_valid(enemigo) and enemigo.has_method("is_alive") and enemigo.is_alive():
			vivos += 1
		elif is_instance_valid(enemigo) and not enemigo.has_method("is_alive"):
			# Si no tiene is_alive, asumimos que está vivo mientras exista
			vivos += 1
	enemigos_restantes = vivos
	if enemigos_restantes <= 0 and not paso_abierto:
		abrir_paso()

func abrir_paso():
	paso_abierto = true
	print("🚪 ¡Todos los enemigos derrotados! Abriendo paso...")
	# Buscar el nodo puertas
	var nodo_puertas = get_node("mapa/puertas")
	if not nodo_puertas:
		nodo_puertas = get_tree().root.find_child("puertas", true, false)
	if nodo_puertas:
		# ====================================================================
		# 1. OCULTAR MARCO1 Y MARCO2
		# ====================================================================
		var marco1 = nodo_puertas.get_node_or_null("marco1")
		if marco1:
			marco1.visible = false
			print("✅ marco1 ocultado")
		var marco2 = nodo_puertas.get_node_or_null("marco2")
		if marco2:
			marco2.visible = false
			print("✅ marco2 ocultado")
		# ====================================================================
		# 2. DESACTIVAR pasar_habitacion (colisión)
		# ====================================================================
		# ====================================================================
		# 3. ACTIVAR ÁREAS DE TELETRANSPORTE
		# ====================================================================
		var area1 = nodo_puertas.get_node_or_null("Area_Puerta1")
		if area1:
			area1.monitoring = true
			print("✅ Area_Puerta1 activada")
		var area2 = nodo_puertas.get_node_or_null("Area_Puerta2")
		if area2:
			area2.monitoring = true
			print("✅ Area_Puerta2 activada")
		var area_sh = nodo_puertas.get_node_or_null("Area_Puerta_SH")
		if area_sh:
			area_sh.monitoring = true
			print("✅ Area_Puerta_SH activada")
	else:
		print("❌ No se encontró el nodo puertas")
