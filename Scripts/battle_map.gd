extends Node2D

class_name BattleMap

# Onready variables
@onready var tilemap_source: TileMap = $TileMapSource
@onready var tile_scene: PackedScene = preload("res://Scenes/Maps/Tiles/tile.tscn")

# Signal
signal tile_clicked(cell_position: Vector2i)

var tiles = {}
var tile_size = Vector2()

# Custom spawn point types
class SpawnPoint:
	var position: Vector2i

	func _init(pos: Vector2i):
		position = pos

class PcSpawnPoint extends SpawnPoint:
	pass

class NpcSpawnPoint extends SpawnPoint:
	pass

# Custom struct for spawn points
class SpawnPoints:
	var pc_spawn_points: Array[PcSpawnPoint]
	var npc_spawn_points: Array[NpcSpawnPoint]

	func _init(pc_points: Array[PcSpawnPoint], npc_points: Array[NpcSpawnPoint]):
		pc_spawn_points = pc_points
		npc_spawn_points = npc_points

func _ready():
	if tile_scene == null:
		push_error("tile_scene is not assigned. Please assign a PackedScene to tile_scene.")
		return

	var tile_instance = tile_scene.instantiate() as Sprite2D
	if tile_instance.texture:
		tile_size = tile_instance.texture.get_size()

	set_process(true)

func get_adjacent_cells(cell: Vector2i) -> Array[Vector2i]:
	var adjacents: Array[Vector2i] = []
	adjacents.append(Vector2i(cell.x - 1, cell.y))      # Top-left
	adjacents.append(Vector2i(cell.x, cell.y - 1))      # Top-right
	adjacents.append(Vector2i(cell.x, cell.y + 1))      # Bottom-left
	adjacents.append(Vector2i(cell.x + 1, cell.y))      # Bottom-right
	return adjacents

func _process(_delta):
	if tile_scene == null:
		return  # Prevent further execution if tile_scene is null

	var mouse_pos = get_global_mouse_position()
	var cell = tilemap_source.local_to_map(mouse_pos)
	snap_in_tiles(cell, 1.0)  # Snap in the hovered tile with full opacity

	# Get adjacent cells for an isometric grid
	var adjacent_cells: Array[Vector2i] = get_adjacent_cells(cell)
	for adj_cell in adjacent_cells:
		snap_in_tiles(adj_cell, 0.15)  # Snap in adjacent tiles with 0.75 opacity

	_fade_out_tiles()


func snap_in_tiles(cell: Vector2i, opacity: float):
	if not tiles.has(cell):
		var tile = tile_scene.instantiate() as Sprite2D
		tile.position = tilemap_source.map_to_local(cell)
		add_child(tile)
		tiles[cell] = tile
		tile.snap_in(opacity)
	else:
		var tile = tiles[cell]
		tile.snap_in(opacity)

func _fade_out_tiles():
	for tile in tiles.values():
		if tile.modulate.a > 0:
			tile.fade_out()

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos: Vector2 = tilemap_source.get_global_mouse_position()
		var cell: Vector2i = tilemap_source.local_to_map(tilemap_source.to_local(mouse_pos))
		cell = Vector2i(floor(cell.x), floor(cell.y))
		print("Tile clicked at position: %s" % cell)
		emit_signal("tile_clicked", cell)

func to_world(grid_position: Vector2i) -> Vector2:
	return tilemap_source.map_to_local(grid_position)

# Method to get spawn points
func get_spawn_points() -> SpawnPoints:
	var pc_spawn_points: Array[PcSpawnPoint] = []
	var npc_spawn_points: Array[NpcSpawnPoint] = []

	var i = 0
	while true:
		var pc_spawn_name = "PcSpawnPoint" + str(i)
		if not tilemap_source.has_node(pc_spawn_name):
			break
		var pc_spawn = tilemap_source.get_node(pc_spawn_name) as Marker2D
		var spawn_point = PcSpawnPoint.new(tilemap_source.local_to_map(pc_spawn.position))
		pc_spawn_points.append(spawn_point)
		i += 1

	i = 0
	while true:
		var npc_spawn_name = "NpcSpawnPoint" + str(i)
		if not tilemap_source.has_node(npc_spawn_name):
			break
		var npc_spawn = tilemap_source.get_node(npc_spawn_name) as Marker2D
		var spawn_point = NpcSpawnPoint.new(tilemap_source.local_to_map(npc_spawn.position))
		npc_spawn_points.append(spawn_point)
		i += 1

	return SpawnPoints.new(pc_spawn_points, npc_spawn_points)
