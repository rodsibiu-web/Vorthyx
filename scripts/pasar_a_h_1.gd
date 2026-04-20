extends TileMapLayer

var slimes_muertos = 0
var puerta_abierta = false
var slime1 = null
var slime2 = null
var slime3 = null
var slime4 = null
var slime5 = null
var slime6 = null
var slime7 = null
var slime8 = null
var slime9 = null
var slime10 = null

# Nombres de los tilemaps que irán arriba del todo
var tilemaps_superiores = ["NombreTileMap1", "NombreTileMap2"]  # CAMBIA ESTOS NOMBRES

func _ready():
	# Configurar tilemaps superiores
	configurar_tilemaps_superiores()
	
	# Resto de tu código original
	buscar_slimes()
	print("🔒 Puerta cerrada. Mata los 10 slimes.")

func configurar_tilemaps_superiores():
	for nombre_tilemap in tilemaps_superiores:
		var tilemap = get_tree().get_root().find_child(nombre_tilemap, true, false)
		if tilemap:
			# Configurar para que esté por encima de todo
			tilemap.z_index = 100  # Número muy alto
			tilemap.show()
			print("✅ TileMap configurado: ", nombre_tilemap, " - z_index: ", tilemap.z_index)
		else:
			print("⚠️ No se encontró el TileMap: ", nombre_tilemap)

func buscar_slimes():
	# Buscar slimes como en tu código original
	slime1 = get_tree().root.find_child("Slime", true, false)
	slime2 = get_tree().root.find_child("Slime2", true, false)
	slime3 = get_tree().root.find_child("Slime3", true, false)
	slime4 = get_tree().root.find_child("Slime4", true, false)
	slime5 = get_tree().root.find_child("Slime5", true, false)
	slime6 = get_tree().root.find_child("Slime6", true, false)
	slime7 = get_tree().root.find_child("Slime7", true, false)
	slime8 = get_tree().root.find_child("Slime8", true, false)
	slime9 = get_tree().root.find_child("Slime9", true, false)
	slime10 = get_tree().root.find_child("Slime10", true, false)

func _process(delta):
	if puerta_abierta:
		return
	
	slimes_muertos = 0
	if slime1 == null or slime1.vida <= 0: slimes_muertos += 1
	if slime2 == null or slime2.vida <= 0: slimes_muertos += 1
	if slime3 == null or slime3.vida <= 0: slimes_muertos += 1
	if slime4 == null or slime4.vida <= 0: slimes_muertos += 1
	if slime5 == null or slime5.vida <= 0: slimes_muertos += 1
	if slime6 == null or slime6.vida <= 0: slimes_muertos += 1
	if slime7 == null or slime7.vida <= 0: slimes_muertos += 1
	if slime8 == null or slime8.vida <= 0: slimes_muertos += 1
	if slime9 == null or slime9.vida <= 0: slimes_muertos += 1
	if slime10 == null or slime10.vida <= 0: slimes_muertos += 1
	
	if slimes_muertos >= 10:
		abrir_puerta()

func abrir_puerta():
	if puerta_abierta:
		return
	
	puerta_abierta = true
	
	# Desactivar colisiones
	set_collision_enabled(false)
	
	# Buscar y ocultar puertas
	var PUERTA_H1 = get_tree().get_root().find_child("FONDO_PUERTA_H2", true, false)
	var PUERTA2_H1 = get_tree().get_root().find_child("FONDO_PUERTA2_H2", true, false)
	var PUERTA_BOSS1 = get_tree().get_root().find_child("MARCO_BOSS", true, false)
	var PUERTA_BOSS2 = get_tree().get_root().find_child("MARCO_BOSS2", true, false)
	
	if PUERTA_H1:
		PUERTA_H1.visible = false
		print("Ocultada: FONDO_PUERTA_H2")
		
	if PUERTA2_H1:
		PUERTA2_H1.visible = false
		print("Ocultada: FONDO_PUERTA2_H2")
		
	if PUERTA_BOSS1:
		PUERTA_BOSS1.visible = false
		print("Ocultada: MARCO_BOSS")
		
	if PUERTA_BOSS2:
		PUERTA_BOSS2.visible = false
		print("Ocultada: MARCO_BOSS2")
	
	print("🚪 PUERTA ABIERTA (10 slimes muertos)")
