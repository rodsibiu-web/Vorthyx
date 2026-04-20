extends Node2D


# Called when the node enters the scene tree for the first time.
func abrir_paso():
	print("🚪 ¡3 orcos muertos! Desbloqueando paso...")
	
	# Mostrar todos los nodos en la escena para depurar
	var todos_los_nodos = get_tree().root.find_children("*", "TileMapLayer", true)
	print("📋 Todos los TileMapLayer encontrados:")
	for nodo in todos_los_nodos:
		print("   - ", nodo.name, " (ruta: ", nodo.get_path(), ")")
	
	# Buscar específicamente PASAR_HABITACION
	var pasar = get_tree().root.find_child("PASAR_HABITACION", true, false)
	if pasar:
		print("✅ PASAR_HABITACION encontrado: ", pasar.name)
		
		# Desactivar colisión
		if pasar.has_method("set_collision_enabled"):
			pasar.set_collision_enabled(false)
		# También por capas
		pasar.collision_layer = 0
		pasar.collision_mask = 0
		# Ocultar visualmente
		pasar.visible = false
		print("✅ PASAR_HABITACION desactivado")
	else:
		print("❌ No se encontró PASAR_HABITACION")
	
	# Buscar Marcos
	var marco1 = get_tree().root.find_child("Marco 1", true, false)
	if marco1:
		marco1.visible = false
		print("✅ Marco 1 ocultado")
	else:
		print("❌ No se encontró Marco 1")
	
	var marco2 = get_tree().root.find_child("Marco 2", true, false)
	if marco2:
		marco2.visible = false
		print("✅ Marco 2 ocultado")
	else:
		print("❌ No se encontró Marco 2")
