extends Node

var slimes_muertos = 0
var jefe_slime = 0
var duendes_habitacion1 = 0    # Total duendes (3 + 4 = 7)
var puerta1_desactivada = false
var puerta2_desactivada = false

func _ready():
	add_to_group("contador")
	print("✅ Contador de enemigos iniciado")

func sumar_slime():
	slimes_muertos += 1
	print("Slimes muertos: ", slimes_muertos)

func sumar_jefe():
	jefe_slime += 1
	print("Jefe Slime muerto")

func sumar_duende_habitacion1():
	duendes_habitacion1 += 1
	print("🔴 DUENDE MUERTO! Total: ", duendes_habitacion1, "/7")
	
	# CUANDO LLEGUE A 7 DUENDES
	if duendes_habitacion1 == 7 and not puerta1_desactivada:
		desactivar_pasar()
	
	if duendes_habitacion1 == 7 and not puerta2_desactivada:
		desactivar_siguiente_habitacion()

# ============================================================================
# DESACTIVAR PASAR (a los 7 duendes)
# ============================================================================
func desactivar_pasar():
	puerta1_desactivada = true
	print("🚪 Desactivando PASAR (7 duendes totales)...")
	
	var pasar = get_tree().root.find_child("PASAR", true, false)
	
	if pasar:
		if pasar.has_method("clear"):
			pasar.clear()
		pasar.visible = false
		pasar.enabled = false
		print("✅ PASAR desactivado")
		
		# OCULTAR MARCOS (también a los 7 duendes)
		var marco1 = get_tree().root.find_child("marco1", true, false)
		if marco1:
			marco1.visible = false
			print("   ✓ Marco 1 ocultado")
		
		var marco2 = get_tree().root.find_child("marco2", true, false)
		if marco2:
			marco2.visible = false
			print("   ✓ Marco 2 ocultado")
		
		# Activar áreas de teletransporte
		var area1 = get_tree().root.find_child("Area_Puerta1", true, false)
		if area1:
			area1.monitoring = true
			area1.monitorable = true
			print("   ✓ Area_Puerta1 activada")
		
		var area2 = get_tree().root.find_child("Area_Puerta2", true, false)
		if area2:
			area2.monitoring = true
			area2.monitorable = true
			print("   ✓ Area_Puerta2 activada")
	else:
		print("❌ No se encontró PASAR")

# ============================================================================
# DESACTIVAR SIGUIENTE_HABITACION (a los 7 duendes)
# ============================================================================
func desactivar_siguiente_habitacion():
	puerta2_desactivada = true
	print("🚪 Desactivando SIGUIENTE_HABITACION...")
	
	var siguiente = get_tree().root.find_child("SIGUIENTE_HABITACION", true, false)
	
	if not siguiente:
		var tiles = get_tree().root.find_children("*", "TileMapLayer", true, false)
		for tile in tiles:
			if tile.name != "PASAR":
				siguiente = tile
				print("✅ Encontrado segundo TileMapLayer: ", tile.name)
				break
	
	if siguiente:
		if siguiente.has_method("clear"):
			siguiente.clear()
		siguiente.visible = false
		siguiente.enabled = false
		print("✅ SIGUIENTE_HABITACION desactivado")
		
		var area_sh = get_tree().root.find_child("Area_Puerta_SH", true, false)
		if area_sh:
			area_sh.monitoring = true
			area_sh.monitorable = true
			print("   ✓ Area_Puerta_SH activada")
	else:
		print("❌ No se encontró SIGUIENTE_HABITACION")
