extends Node2D

class_name BattleMap

# Onready variables
@onready var tilemap_source: TileMap = $TileMapSource
@onready var tile_scene: PackedScene = preload("res://Scenes/Maps/Tiles/tile.tscn")

var tiles = {}
var tile_size = Vector2()
var actors = {}

# Distance cache
var distance_cache = {}

# Custom struct for spawn points
class SpawnPoints:
	var pc_spawn_points: Array[Vector2i]
	var npc_spawn_points: Array[Vector2i]

	func _init(pc_points: Array[Vector2i], npc_points: Array[Vector2i]):
		pc_spawn_points = pc_points
		npc_spawn_points = npc_points

func _ready():
	if tile_scene == null:
		push_error("tile_scene is not assigned. Please assign a PackedScene to tile_scene.")
		return

	var source_tiles = tilemap_source.get_used_cells(0)
	for cell in source_tiles:
		var tile_sprite = tile_scene.instantiate() as Sprite2D
		add_child(tile_sprite)
		tiles[cell] = tile_sprite
		tile_sprite.position = tilemap_source.map_to_local(cell)
		if is_tile_impassable(cell):
			tile_sprite.set_impassable()
		
	set_process(true)

func _process(delta):
	_fade_out_tiles()

func get_adjacent_cells(cell: Vector2i) -> Array[Vector2i]:
	var adjacents: Array[Vector2i] = []
	adjacents.append(Vector2i(cell.x - 1, cell.y))
	adjacents.append(Vector2i(cell.x + 1, cell.y))
	adjacents.append(Vector2i(cell.x, cell.y - 1))
	adjacents.append(Vector2i(cell.x, cell.y + 1))
	adjacents.append(Vector2i(cell.x - 1, cell.y - 1))
	adjacents.append(Vector2i(cell.x + 1, cell.y + 1))
	adjacents.append(Vector2i(cell.x - 1, cell.y + 1))
	adjacents.append(Vector2i(cell.x + 1, cell.y - 1))
	return adjacents

func highlight_tile(cell: Vector2i, opacity: float = 1.0):
	snap_in_tiles(cell, opacity)

func snap_in_tiles(cell: Vector2i, opacity: float):
	if tiles.has(cell):
		tiles.get(cell).snap_in(opacity)

func _fade_out_tiles():
	for tile in tiles.values():
		tile.fade_out()

func to_world(grid_position: Vector2i) -> Vector2:
	return tilemap_source.map_to_local(grid_position)
	
func to_cell(screen_position: Vector2) -> Vector2i:
	return tilemap_source.local_to_map(screen_position)

func get_spawn_points() -> SpawnPoints:
	var pc_spawn_points: Array[Vector2i] = []
	var npc_spawn_points: Array[Vector2i] = []

	var i = 0
	while true:
		var pc_spawn_name = "PcSpawnPoint" + str(i)
		if not tilemap_source.has_node(pc_spawn_name):
			break
		var pc_spawn = tilemap_source.get_node(pc_spawn_name) as Marker2D
		var spawn_point = tilemap_source.local_to_map(pc_spawn.position)
		pc_spawn_points.append(spawn_point)
		i += 1

	i = 0
	while true:
		var npc_spawn_name = "NpcSpawnPoint" + str(i)
		if not tilemap_source.has_node(npc_spawn_name):
			break
		var npc_spawn = tilemap_source.get_node(npc_spawn_name) as Marker2D
		var spawn_point = tilemap_source.local_to_map(npc_spawn.position)
		npc_spawn_points.append(spawn_point)
		i += 1

	return SpawnPoints.new(pc_spawn_points, npc_spawn_points)

func is_tile_impassable(cell: Vector2i) -> bool:
	var tile_id = tilemap_source.get_cell_source_id(0, cell)
	return tile_id == 1

func add_actor(actor: Actor, position: Vector2i):
	actors[actor] = position

func move_actor_position(actor:Actor, position: Vector2i):
	actors.erase(actor)
	actors[actor] = position

func remove_actor(actor: Actor):
	actors.erase(actor)

func get_actor_position(actor: Actor) -> Vector2i:
	return actors.get(actor, Vector2i(-1, -1))

func get_actors_in_radius(center: Vector2i, radius: int) -> Array[Actor]:
	var result = []
	var distance_data = calculate_distances(center, radius, Vector2i(0, 0))
	var distance_map = distance_data["distance_map"]
	for actor in actors.keys():
		var pos = actors[actor]
		if distance_map.has(pos) and distance_map[pos] <= radius:
			result.append(actor)
	return result

func get_actors_in_square(top_left: Vector2i, bottom_right: Vector2i) -> Array[Actor]:
	var result: Array[Actor] = []
	for actor in actors.keys():
		var pos = actors[actor]
		if pos.x >= top_left.x and pos.x <= bottom_right.x and pos.y >= top_left.y and pos.y <= bottom_right.y:
			result.append(actor)
	return result

func get_actors_in_emanation(center: Vector2i, size: Vector2i, radius: int) -> Array[Actor]:
	var result = []
	var distance_data = calculate_distances(center, radius, size)
	var distance_map = distance_data["distance_map"]
	for actor in actors.keys():
		var pos = actors[actor]
		if distance_map.has(pos) and distance_map[pos] <= radius:
			result.append(actor)
	return result

func get_shortest_walking_path(start: Vector2i, target: Vector2i) -> Array[Vector2i]:
	return calculate_shortest_path(start, target, true)

func get_walking_distance(target: Vector2i, path: Array[Vector2i], consider_terrain: bool = false) -> int:
	var initial =  calculate_step_distance(path, consider_terrain)
	var full_path: Array[Vector2i] = path.duplicate()
	full_path.append(target)
	var final = calculate_step_distance(full_path, consider_terrain) 
	return final - initial

# Implements Pathfinder 2e diagonal rules by iterating through the path and counting diagonals
func calculate_step_distance(path: Array[Vector2i], consider_terrain: bool = false) -> int:
	var distance = 0
	var diagonal_count = 0

	for i in range(1, path.size()):
		var current = path[i - 1]
		var next = path[i]

		var dx = abs(next.x - current.x)
		var dy = abs(next.y - current.y)
		var step_distance = 0
		
		if dx == 0 and dy == 0:
			# No movement, distance is zero
			step_distance = 0
		elif dx == 1 and dy == 1:
			diagonal_count += 1
			step_distance = 1 if diagonal_count % 2 == 1 else 2
		elif (dx == 1 and dy == 0) or (dx == 0 and dy == 1):
			step_distance = 1
		else:
			# If the movement is neither rectilinear nor valid diagonal, raise an error
			push_error("Invalid movement from (%d, %d) to (%d, %d): the step is neither rectilinear nor a valid diagonal. Path: %s"
					   % [current.x, current.y, next.x, next.y, path])
		
		if consider_terrain and step_distance > 0:
			step_distance *= get_tile_cost(next)
		
		distance += step_distance

	return distance



func get_tile_cost(cell: Vector2i) -> int:
	var tile_id = tilemap_source.get_cell_source_id(0, cell)
	match tile_id:
		1:
			return 999999
		2:
			return 2
		3:
			return 4
		_:
			return 1

func get_actors_in_area(center: Vector2i, size: Vector2i, area: Array[Vector2i]) -> Array[Actor]:
	var result = []
	for actor in actors.keys():
		var actor_pos = actors[actor]
		for offset in area:
			if actor_pos == center + offset:
				result.append(actor)
				break
	return result

func get_emanation(center: Vector2i, size: Vector2i, radius: int, consider_terrain: bool = false, from_path: Array[Vector2i] = []) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	from_path.append(center)
	var distance_data = calculate_distances_from_path(from_path, radius, size, consider_terrain)
	var distance_map = distance_data["distance_map"]
	for pos in distance_map.keys():
		if distance_map[pos] <= radius:
			result.append(pos)
	return result

# Implement calculate_shortest_path to find path from start to target
func calculate_shortest_path(
	start: Vector2i,
	target: Vector2i,
	consider_terrain: bool = false
) -> Array[Vector2i]:
	var dijkstra = Dijkstra.new()
	
	# Define the get_neighbors function
	var neighbor_fn = func (node: Vector2i) -> Array:
		return get_adjacent_cells(node)
	
	# Define the calculate_distance function
	var distance_fn = func (arrayPath: Array) -> int:
		var path: Array[Vector2i] = []
		for point in arrayPath:
			if point is Vector2i:
				path.append(point)
			else:
				path.append(Vector2i(point))
		return calculate_step_distance(path, consider_terrain)
	
	# Calculate the shortest path using Dijkstra's algorithm
	var nodes = dijkstra.calculate_shortest_path(start, target, neighbor_fn, distance_fn)
	var path: Array[Vector2i]
	for node in nodes:
		path.append(node)
	return path

func calculate_distances(
	start: Vector2i,
	max_distance: int = 10,
	footprint: Vector2i = Vector2i(0, 0),
	consider_terrain: bool = false
) -> Dictionary:
	var startPath: Array[Vector2i] = []
	startPath.append(start)
	return calculate_distances_from_path(startPath, max_distance, footprint, consider_terrain)
	
func calculate_distances_from_path(
	start: Array[Vector2i],
	max_distance: int = 10,
	footprint: Vector2i = Vector2i(0, 0),
	consider_terrain: bool = false
) -> Dictionary:
	start = start.duplicate()
	# Check cache first
	var cache_key = str(start) + "_" + str(max_distance) + "_" + str(footprint) + "_" + str(consider_terrain)
	if distance_cache.has(cache_key):
		return distance_cache[cache_key]
	var start_pos = start.front()

	# Get initial positions based on the footprint
	var initial_positions = get_initial_positions(start_pos, footprint)

	# Define the get_neighbors function
	var neighbor_fn = func get_neighbors(node: Vector2i) -> Array:
		return get_adjacent_cells(node)  # Implement this method based on your requirements
	# Define the calculate_distance function
	var distance_fn = func calculate_distance(arrayPath: Array) -> int:
	# Convert each element in the path array to Vector2i if it is not already
		var path: Array[Vector2i] = start.duplicate()
		for point in arrayPath:
			path.append(Vector2i(point))
		return calculate_step_distance(path, consider_terrain)


	# Create an instance of Dijkstra class and calculate distances
	var dijkstra = Dijkstra.new()
	var result = dijkstra.calculate_distances(start_pos, max_distance, initial_positions, neighbor_fn, distance_fn)
	# Cache the result
	distance_cache[cache_key] = result

	return result


func get_initial_positions(start: Vector2i, footprint: Vector2i) -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	if footprint == Vector2i(0, 0):
		positions.append(start)
		positions.append(Vector2i(start.x + 1, start.y))
		positions.append(Vector2i(start.x, start.y + 1))
		positions.append(Vector2i(start.x + 1, start.y + 1))
	else:
		for x in range(start.x - footprint.x, start.x + footprint.x + 1):
			for y in range(start.y - footprint.y, start.y + footprint.y + 1):
				positions.append(Vector2i(x, y))
	return positions
