extends Node2D

var puerta_abierta = false

func _process(delta):
	if not puerta_abierta and Input.is_key_pressed(KEY_SHIFT) and Input.is_key_pressed(KEY_E):
		abrir_puerta()

func abrir_puerta():
	# Abrir puerta (la que tiene colisión)
	if has_node("FONDO/PUERTA"):
		$FONDO/PUERTA.set_collision_enabled(false)
		print("Puerta abierta")
	
	# Ocultar FONDO_PUERTA y FONDO_PUERTA2
	if has_node("FONDO/FONDO_PUERTA"):
		$FONDO/FONDO_PUERTA.visible = false
		print("FONDO_PUERTA oculto")
	
	if has_node("FONDO/FONDO_PUERTA2"):
		$FONDO/FONDO_PUERTA2.visible = false
		print("FONDO_PUERTA2 oculto")
	
	puerta_abierta = true
