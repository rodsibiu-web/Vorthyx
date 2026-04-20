extends Area2D

enum TipoCarta {
	VIDA,
	ESPADA,
	BOTA,
	FUEGO
}

@export var tipo: TipoCarta = TipoCarta.VIDA
@export var valor: float = 0.0

@onready var sprite = $Sprite2D
var recolectada = false

var valores_defecto = {
	"VIDA": 20,
	"ESPADA": 2.5,
	"BOTA": 50,
	"FUEGO": 5
}

func _ready():
	cargar_imagen()
	
	if valor == 0:
		valor = valores_defecto[TipoCarta.keys()[tipo]]
	
	animar_flotacion()
	body_entered.connect(_on_body_entered)

func cargar_imagen():
	var ruta = ""
	match tipo:
		TipoCarta.VIDA:
			ruta = "res://Y-Integrantes/Iker/carta heal.png"
		TipoCarta.ESPADA:
			ruta = "res://Y-Integrantes/Iker/carta ataque.png"
		TipoCarta.BOTA:
			ruta = "res://Y-Integrantes/Iker/carta speed.png"
		TipoCarta.FUEGO:
			ruta = "res://Y-Integrantes/Iker/carta fuego.png"
	
	if ResourceLoader.exists(ruta):
		sprite.texture = load(ruta)
	else:
		var ruta_base = "res://Y-Integrantes/Iker/carta base.png"
		if ResourceLoader.exists(ruta_base):
			sprite.texture = load(ruta_base)

func animar_flotacion():
	# Crear tween para la animación de flotación
	var tween = create_tween()
	
	# Configurar loops infinitos (0 = infinito)
	tween.set_loops(0)
	
	# Guardar posición inicial para evitar problemas de referencia
	var pos_inicial = position
	
	# Animación de subida
	tween.tween_property(self, "position", pos_inicial + Vector2(0, -5), 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	# Animación de bajada
	tween.tween_property(self, "position", pos_inicial, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body):
	if recolectada:
		return
	
	# Detectar tanto al jugador 1 como al jugador 2
	if body.is_in_group("player") or body.is_in_group("player2"):
		recolectada = true
		print("📜 ", body.name, " ha recogido una carta de tipo: ", TipoCarta.keys()[tipo])
		
		# Añadir carta al inventario compartido (Sistema_Guardado)
		var ruta_imagen = get_ruta_imagen()
		Sistema_Guardado.añadir_carta(TipoCarta.keys()[tipo], valor, ruta_imagen)
		
		# Aplicar efecto visual de recogida
		efecto_recogida()
		
		# Eliminar la carta del mundo después del efecto
		await get_tree().create_timer(0.2).timeout
		queue_free()

func get_ruta_imagen():
	match tipo:
		TipoCarta.VIDA:
			return "res://Y-Integrantes/Iker/carta heal.png"
		TipoCarta.ESPADA:
			return "res://Y-Integrantes/Iker/carta ataque.png"
		TipoCarta.BOTA:
			return "res://Y-Integrantes/Iker/carta speed.png"
		TipoCarta.FUEGO:
			return "res://Y-Integrantes/Iker/carta fuego.png"
	return ""

func efecto_recogida():
	# Efecto de recogida: escala y desvanecimiento
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite, "modulate:a", 0, 0.15).set_ease(Tween.EASE_IN)
