extends Node
## Único punto de acoplamiento entre el juego y las herramientas de
## depuración (tools/). Ninguna escena del juego (demoland.tscn, etc.)
## menciona nada de tools/ directamente. En cambio, ObstaculoViento y
## VientoRegional se auto-etiquetan con un grupo de Godot al arrancar
## (una simple etiqueta de texto, no una dependencia real hacia esta
## carpeta), y este script busca esos grupos y les cuelga la flecha
## y la cruceta POR CÓDIGO, sin que ninguna escena las mencione.
##
## El único acople real que queda es la línea de Autoload en
## Configuración del Proyecto que registra este mismo script. Si algún
## día se borra tools/ completo, alcanza con sacar esa única línea —
## ninguna escena del juego queda con una referencia rota.
##
## Simplificación consciente para esta etapa: toma el primer
## VientoRegional que encuentra en todo el árbol y lo asocia a
## cualquier obstáculo. Correcto mientras exista un solo mapa; cuando
## la Etapa 8 traiga varios mapas a la vez, esto va a necesitar
## asociar cada obstáculo con el VientoRegional de SU propio mapa, no
## con "el primero que aparezca".

func _ready() -> void:
	call_deferred("_montar_herramientas")


func _montar_herramientas() -> void:
	var vientos: Array = get_tree().get_nodes_in_group("viento_regional")
	var obstaculos: Array = get_tree().get_nodes_in_group("obstaculo_viento")

	for nodo_viento in vientos:
		_montar_flecha(nodo_viento as VientoRegional)

	if vientos.is_empty():
		return

	var viento_asociado: VientoRegional = vientos[0] as VientoRegional
	for nodo_obstaculo in obstaculos:
		_montar_cruceta(nodo_obstaculo as ObstaculoViento, viento_asociado)


func _montar_flecha(viento: VientoRegional) -> void:
	if viento == null:
		return
	var flecha := FlechaViento.new()
	flecha.viento = viento
	viento.get_parent().add_child(flecha)


func _montar_cruceta(obstaculo: ObstaculoViento, viento: VientoRegional) -> void:
	if obstaculo == null or viento == null:
		return
	var cruceta := CruzetaZonaCalma.new()
	cruceta.obstaculo = obstaculo
	cruceta.viento = viento
	obstaculo.get_parent().add_child(cruceta)
