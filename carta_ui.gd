extends Panel

@onready var icono = $Icono
@onready var nombre_label = $Nombre

var item = null

func setup(carta):
	item = carta
	icono.texture = load(carta.ruta_imagen) if carta.has("ruta_imagen") else null
	nombre_label.text = carta.tipo

func _on_mouse_entered():
	# Levanta la carta cuando el mouse está encima
	var tween = create_tween()
	tween.tween_property(self, "position", position - Vector2(0, 20), 0.2)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)

func _on_mouse_exited():
	# Vuelve a su lugar cuando el mouse sale
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, 20), 0.2)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
