extends TileMapLayer

func _ready():
	print("FONDO_PUERTA listo")

func _process(delta):
	if not visible:
		print("ALGUIEN OCULTÓ FONDO_PUERTA en frame: ", Engine.get_frames_drawn())
