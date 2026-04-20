extends Panel

@onready var icon = $Icon
@onready var quantity_label = $Quantity

var item_data = null
var slot_index = -1

func setup(item, index):
	item_data = item
	slot_index = index
	if item:
		icon.texture = item.icon
		# Si hay cantidad y es mayor que 1, se muestra; si no, texto vacío
		if item.has("quantity") and item.quantity > 1:
			quantity_label.text = str(item.quantity)
		else:
			quantity_label.text = ""
	else:
		icon.texture = null
		quantity_label.text = ""

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if item_data:
			usar_item()

func usar_item():
	# Avisar al inventario principal
	var inventory_ui = get_node("CanvasLayer/InventoryUI")
	if inventory_ui:
		inventory_ui.usar_item(slot_index)
