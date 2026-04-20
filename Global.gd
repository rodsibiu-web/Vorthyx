extends Node

var cartas_recogidas = []

func añadir_carta(tipo, valor, ruta_imagen):
	for carta in cartas_recogidas:
		if carta["tipo"] == tipo:
			carta["valor"] += valor
			carta["cantidad"] += 1
			print("📦 Acumulado: ", tipo, " +", valor, " (Total: ", carta["valor"], " x", carta["cantidad"], ")")
			return
	
	cartas_recogidas.append({
		"tipo": tipo,
		"valor": valor,
		"cantidad": 1,
		"ruta_imagen": ruta_imagen
	})
	print("📦 Nueva carta: ", tipo, " +", valor)
