extends Node

var slimes_matados = 0

func guardar_slimes():
	var slimes = get_tree().get_nodes_in_group("enemigos")
	var vivos = 0
	for s in slimes:
		if s.vida > 0:
			vivos += 1
	slimes_matados = 10 - vivos
	print("💾 Slimes matados: ", slimes_matados)

func cargar_slimes():
	print("📀 Cargando slimes matados: ", slimes_matados)
	var slimes = get_tree().get_nodes_in_group("enemigos")
	var a_eliminar = slimes_matados
	for s in slimes:
		if a_eliminar > 0:
			s.queue_free()
			a_eliminar -= 1	
