extends TileMapLayer

var puerta_abierta = false

func _ready():
	print("🔒 Puerta cerrada. Mata 3 slimes.")

func _process(delta):
	if puerta_abierta:
		return
	
	var global_node = get_node("/root/Node2D/VAR_ENEMIGOS")
	if global_node and global_node.slimes_muertos >= 3:
		abrir_puerta()

func abrir_puerta():
	puerta_abierta = true
	set_collision_enabled(false)
	print("🔓 PUERTA ABIERTA (3 slimes muertos)")
	
	# SOLO CUANDO SE ABRE LA PUERTA se ocultan los fondos
	var fondo1 = get_tree().root.find_child("FONDO_PUERTA", true, false)
	var fondo2 = get_tree().root.find_child("FONDO_PUERTA2", true, false)
	if fondo1:
		fondo1.visible = false
		print("FONDO_PUERTA ocultado")
	if fondo2:
		fondo2.visible = false
		print("FONDO_PUERTA2 ocultado")
