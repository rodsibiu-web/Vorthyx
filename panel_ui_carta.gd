extends Panel

@onready var grid = $GridContainer
@onready var titulo = $Titulo

func _ready():
	# Configurar estilo por código (alternativa al inspector)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7)  # Negro semitransparente
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(1, 1, 1, 0.8)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	
	add_theme_stylebox_override("panel", style)
	
	# Título
	titulo.text = "INVENTARIO"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 24)
	titulo.add_theme_color_override("font_color", Color(1, 1, 1))
	
	visible = false

func mostrar():
	visible = true

func ocultar():
	visible = false

func _input(event):
	if event.is_action_just_pressed("inventario"):
		if visible:
			ocultar()
		else:
			mostrar()
