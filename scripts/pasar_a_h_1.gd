extends TileMapLayer

var slimes_muertos = 0
var puerta_abierta = false
var slime1 = null
var slime2 = null
var slime3 = null

func _ready():
	# Buscar los 3 slimes
	slime1 = get_tree().root.find_child("Slime", true, false)
	slime2 = get_tree().root.find_child("Slime2", true, false)
	slime3 = get_tree().root.find_child("Slime3", true, false)
	
	print("🔒 Puerta cerrada. Mata los 3 slimes.")

func _process(delta):
	if puerta_abierta:
		return
	
	# Contar slimes vivos
	slimes_muertos = 0
	if slime1 == null or slime1.vida <= 0:
		slimes_muertos += 1
	if slime2 == null or slime2.vida <= 0:
		slimes_muertos += 1
	if slime3 == null or slime3.vida <= 0:
		slimes_muertos += 1
	
	if slimes_muertos >= 3:
		abrir_puerta()

func abrir_puerta():
	if puerta_abierta:
		return
	
	puerta_abierta = true
	set_collision_enabled(false)
	print("🚪 PUERTA ABIERTA (3 slimes muertos)")
	
	var fondo1 = get_tree().get_root().find_child("FONDO_PUERTA", true, false)
	var fondo2 = get_tree().get_root().find_child("FONDO_PUERTA2", true, false)
	
	if fondo1:
		fondo1.visible = false
	if fondo2:
		fondo2.visible = false
