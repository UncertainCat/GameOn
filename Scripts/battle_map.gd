extends Node2D

class_name BattleMap

# Exported variables
@onready var tilemap_source = $TileMapSource

# Internal TileMap for display
var tilemap_display: TileMap

signal tile_clicked(cell_position: Vector2i)

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
	# Create and attach the tilemap_display
	tilemap_display = TileMap.new()
	add_child(tilemap_display)

	# Set up the tilemaps
	_setup_tilemap_source()

	# Connect the mouse input event
	tilemap_display.connect("gui_input", Callable(self, "_on_gui_input"))

func _setup_tilemap_source():
	if tilemap_source != null:
		tilemap_source.visible = false
		tilemap_source.connect("ready", Callable(self, "_on_tilemap_source_ready"))
	else:
		push_error("tilemap_source is null in _setup_tilemap_source!")

func _on_tilemap_source_ready():
	if tilemap_source != null and tilemap_display != null:
		tilemap_display.tile_set = tilemap_source.tile_set
		tilemap_display.tile_origin = tilemap_source.tile
		tilemap_display.cell_size = tilemap_source.cell_size
		tilemap_display.mode = TileMap.MODE_SQUARE
		_sync_tilemaps()
	else:
		push_error("tilemap_source or tilemap_display is null in _on_tilemap_source_ready!")

func _sync_tilemaps():
	if tilemap_source != null and tilemap_display != null:
		for cell in tilemap_source.get_used_cells(0):
			var tile_id = tilemap_source.get_cell(0, cell)
			tilemap_display.set_cell(0, cell, tile_id)
	else:
		push_error("tilemap_source or tilemap_display is null in _sync_tilemaps!")

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MouseButton.LEFT and event.pressed:
		var mouse_pos: Vector2 = tilemap_display.get_global_mouse_position()
		var cell: Vector2i = tilemap_display.local_to_map(tilemap_display.to_local(mouse_pos))
		print("Tile clicked at position: %s" % cell)
		emit_signal("tile_clicked", cell)
	elif event is InputEventMouseMotion:
		var mouse_pos: Vector2 = tilemap_display.get_global_mouse_position()
		var cell: Vector2i = tilemap_display.local_to_map(tilemap_display.to_local(mouse_pos))
		_update_displayed_tile(cell)

func _update_displayed_tile(cell: Vector2i):
	tilemap_display.clear()
	var tile_id = tilemap_source.get_cell(0, cell)
	if tile_id != -1:
		tilemap_display.set_cell(0, cell, tile_id)

func _on_tile_clicked(cell_position: Vector2i):
	print("Tile clicked signal received: %s" % cell_position)
	var event = Event.new()
	event.type = "move_player"
	event.data = {"position": cell_position}
	event_bus.publish_event(event)

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
