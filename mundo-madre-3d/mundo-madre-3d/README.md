# Mundo Madre — Etapa 0: Esqueleto jugable

Proyecto Godot 4.7.1, 3D, desde cero. Corresponde estrictamente a la Etapa 0
de la hoja de ruta: un personaje se mueve sobre una escena mínima, y un PNJ
patrulla con una máquina de estados simple. Nada más — ni reloj de
simulación, ni ambiente, ni cuerpos celestes. Eso es la Etapa 1 en adelante.

## Cómo abrirlo

1. Abrí Godot 4.7.1.
2. "Importar" → seleccioná la carpeta de este proyecto → Abrir.
3. F5 para correr, o F6 sobre `scenes/main.tscn`.

## Controles

- W/A/S/D: mover al personaje. El movimiento está alineado a los ejes de
  la cámara isométrica fija, no a los ejes absolutos del mundo.

## Qué decisiones tomé y por qué

- **Cámara isométrica fija al personaje**: es hija directa del `CharacterBody3D`
  del jugador, con ángulo constante (pitch -40°, yaw 45° por defecto, ambos
  exportados como variables si querés ajustarlos desde el Inspector). No hay
  rotación ni desplazamiento independiente en esta etapa — coincide con lo
  que pediste: referencia visual de BG3/The Sims, pero sin su libertad de
  cámara.
- **Todo construido por código en `_ready()`, nada de mallas o formas
  de colisión pre-armadas en los `.tscn`**: el radio y la altura de la
  cápsula del jugador y del PNJ alimentan tanto la malla visual como la
  forma de colisión desde el mismo par de variables — es el Principio 1
  del documento de visión aplicado literalmente (nada se fija a mano dos
  veces). El suelo, la luz y el entorno de `scenes/main.gd` son igual de
  procedurales: cero dependencia de recursos importados en esta etapa.
- **Los puntos de patrulla del PNJ son hijos del propio PNJ**, no
  referencias externas al mapa. La entidad es autosuficiente — se puede
  arrastrar a cualquier escena futura sin que se rompan referencias. Esto
  es intencional pensando en la Etapa 10 (voluntad propia): la base de
  movimiento no debería tener que rehacerse cuando se le agregue esa capa.
- **La luz direccional es un marcador de presentación, no una entidad
  simulada.** Lo digo explícito en el comentario del código para que no se
  confunda con el sol real de la Etapa 4. Todavía no hay nada que "sienta"
  esa luz — eso es la Etapa 2.
- **No usé el sistema de InputMap de Godot.** Leo las teclas directo
  (`Input.is_key_pressed`) para no tener que serializar a mano la sección
  `[input]` de `project.godot`, que es propensa a errores si se escribe
  sin el editor. Cuando el control se vuelva más complejo (Etapa 3 en
  adelante, con el jugador como causa), conviene migrar a InputMap con
  el editor abierto — lo señalo para no perderlo de vista.

## Qué validé y qué no

Descargué el binario oficial de Godot 4.7.1 para Linux y corrí el proyecto
en modo `--headless`:

- `--import`: sin errores de sintaxis en ningún `.tscn` ni `.gd`.
- 120 frames de ejecución real de `main.tscn`: sin excepciones ni
  advertencias en consola (gravedad, colisión contra el suelo, y la
  máquina de estados del PNJ corrieron sin romperse).

Lo que **no** pude validar acá, porque este entorno no tiene pantalla: que
el ángulo de cámara se sienta bien, que los colores y proporciones se vean
como esperás, y que el movimiento W/A/S/D se sienta natural respecto a lo
que ves en pantalla. Esa parte la tenés que confirmar vos al abrirlo. Si el
ángulo o la distancia de cámara no te convencen, `camera_yaw_degrees`,
`camera_pitch_degrees` y `camera_distance` están expuestos en el Inspector
del nodo Player para que los ajustes sin tocar código.

## Estructura

```
project.godot
entities/
  player/
    player.gd       # cuerpo, movimiento, cámara isométrica fija
    player.tscn
  npc/
    npc.gd           # máquina de estados IDLE <-> PATROL
    npc.tscn
scenes/
  main.gd            # construye suelo, luz y entorno por código
  main.tscn           # instancia Player y NPC
```
