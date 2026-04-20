extends Control

@onready var grid = $ItemsGrid  # Asegúrate de que el GridContainer se llama ItemsGrid
var slot_scene = preload("res://Y-Integrantes/Iker/inventory_slot.tscn")
var inventory_items = []   # array de ItemData
var player = null

func _ready():
	# Buscar al jugador (ajusta la ruta según tu estructura)
	player = get_node("CharacterBody2D")   # O dentro de CanvasLayer? Ajusta.
	# Si usas CanvasLayer, la ruta puede ser /root/Node2D/CanvasLayer/CharacterBody2D
	# Pero lo más fácil: usar group "player" -> player = get_tree().get_first_node_in_group("player")
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	
	# Opcional: añadir objetos de prueba
	# inventory_items.append(preload("res://inventario/items/carta_vida.tres"))
	
	actualizar_ui()

func actualizar_ui():
	for child in grid.get_children():
		child.queue_free()
	for i in range(inventory_items.size()):
		var slot = slot_scene.instantiate()
		grid.add_child(slot)
		slot.setup(inventory_items[i], i)

func add_item(new_item: ItemData) -> bool:
	# Si quieres límite de slots:
	if inventory_items.size() >= 20:
		return false
	inventory_items.append(new_item)
	actualizar_ui()
	return true

func usar_item(index):
	var item = inventory_items[index]
	if not item:
		return
	
	match item.type:
		"health":
			player.curar(item.value)
		"damage":
			player.aumentar_dano(item.value)
		"speed":
			player.aumentar_velocidad(item.value)
	
	inventory_items.remove_at(index)
	actualizar_ui()
