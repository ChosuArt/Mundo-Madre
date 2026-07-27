class_name VientoObstaculoMath
extends RefCounted
## Geometría y deflexión del viento alrededor de un obstáculo sólido.
## Misma familia que ThermalMath/SolarMath (Principio 6 del documento
## de visión): función pura, sin nodos ni estado propio — le entran
## números, le salen números. Nunca decide nada sobre cómo se dibuja
## nada; eso es responsabilidad exclusiva de la capa de presentación
## (Principio 3).
##
## El obstáculo se describe solo con radio y altura (Principio 1): el
## tamaño de su zona de calma se DERIVA de esos dos números, nunca se
## guarda como un tercer valor suelto que alguien deba mantener
## sincronizado a mano.


## Dimensiones de la zona de calma como semi-extensiones medidas desde
## la BASE del obstáculo (el punto donde toca el suelo):
## - ancho: hacia los costados (+/-), perpendicular al viento.
## - largo: hacia sotavento (a favor del viento), desde el borde del
##   obstáculo hasta donde el viento regional vuelve a imponerse.
## - alto: desde el suelo hacia arriba — por encima de esta altura el
##   viento pasa por encima del obstáculo sin deformarse.
static func calcular_zona_calma(radio: float, altura: float, factor_largo: float = 4.0) -> Dictionary:
	return {
		"ancho": radio,
		"largo": (radio * 2.0 + altura) * factor_largo * 0.5,
		"alto": altura,
	}


## Vector de viento real en un punto, considerando un único obstáculo.
## `punto_relativo` debe venir ya expresado como (punto_mundo -
## posicion_base_del_obstaculo) — el obstáculo no rota, así que no
## hace falta deshacer ninguna orientación antes de llamar a esto.
static func deflectar(
	punto_relativo: Vector3,
	direccion_viento: Vector3,
	velocidad_viento: float,
	radio: float,
	altura: float,
	factor_largo: float = 4.0
) -> Vector3:
	var viento_libre: Vector3 = direccion_viento * velocidad_viento
	if velocidad_viento <= 0.0001 or direccion_viento.length_squared() <= 0.0001:
		return viento_libre

	# Por encima del obstáculo el viento pasa de largo: no hay nada
	# que lo desvíe a esa altura.
	if punto_relativo.y > altura:
		return viento_libre

	var direccion: Vector3 = direccion_viento.normalized()
	var lateral: Vector3 = direccion.cross(Vector3.UP)
	if lateral.length_squared() <= 0.0001:
		return viento_libre
	lateral = lateral.normalized()

	# 'a' = distancia a lo largo del eje del viento (positivo =
	# sotavento, la cara protegida). 'b' = desplazamiento lateral
	# respecto a ese mismo eje.
	var a: float = punto_relativo.dot(direccion)
	var b: float = punto_relativo.dot(lateral)

	var zona: Dictionary = calcular_zona_calma(radio, altura, factor_largo)
	var ancho: float = zona.ancho
	var largo: float = zona.largo

	# Cara de barlovento (donde el viento golpea primero): se desvía
	# lateralmente en vez de atravesar el obstáculo.
	if a >= -radio and a <= 0.0 and abs(b) <= ancho:
		var lado: float = sign(b) if b != 0.0 else 1.0
		var empuje: float = (1.0 - abs(b) / ancho) * 0.6
		var nueva_direccion: Vector3 = (direccion + lateral * lado * empuje).normalized()
		return nueva_direccion * velocidad_viento

	# Estela protegida: se va cerrando en cono a medida que se aleja,
	# hasta que el viento regional vuelve a imponerse.
	if a > 0.0 and a <= largo and abs(b) <= ancho:
		var progreso: float = a / largo
		var ancho_permitido: float = ancho * (1.0 - progreso)
		if abs(b) <= ancho_permitido:
			return viento_libre * lerp(0.1, 1.0, progreso)

	return viento_libre
