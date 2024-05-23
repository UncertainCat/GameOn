extends Node2D

class_name BattleMap

# Onready variables
@onready var tilemap_source: TileMap = $TileMapSource
@onready var tile_scene: PackedScene = preload("res://Scenes/Maps/Tiles/tile.tscn")

var tiles = {}
var tile_size = Vector2()
var actors = {}

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

func highlight_tile(cell: Vector2i, opacity: float = 1.0):
	snap_in_tiles(cell, opacity)

	# Get adjacent cells for an isometric grid
	var adjacent_cells: Array[Vector2i] = get_adjacent_cells(cell)
	for adj_cell in adjacent_cells:
		snap_in_tiles(adj_cell, 0.15)

	_fade_out_tiles()

func snap_in_tiles(cell: Vector2i, opacity: float):
	if not tiles.has(cell):
		var tile = tile_scene.instantiate() as Sprite2D
		tile.position = tilemap_source.map_to_local(cell)
		add_child(tile)
		tiles[cell] = tile
		if is_tile_impassable(cell):
			tile.set_impassable()
		tile.snap_in(opacity)
	else:
		var tile = tiles[cell]
		tile.snap_in(opacity)

func _fade_out_tiles():
	for tile in tiles.values():
		tile.fade_out()

func to_world(grid_position: Vector2i) -> Vector2:
	return tilemap_source.map_to_local(grid_position)
	
func to_cell(screen_position: Vector2) -> Vector2i:
	return tilemap_source.local_to_map(screen_position)

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

func is_tile_impassable(cell: Vector2i) -> bool:
	return get_tile_cost(cell) == float('inf')

# Method to add an actor to the map
func add_actor(actor: Actor, position: Vector2i):
	actors[actor] = position

# Method to remove an actor from the map
func remove_actor(actor: Actor):
	actors.erase(actor)

# Method to get the position of an actor
func get_actor_position(actor: Actor) -> Vector2i:
	return actors.get(actor, Vector2i(-1, -1))  # Return invalid position if actor not found

# Method to get actors within a radius
func get_actors_in_radius(center: Vector2i, radius: int) -> Array[Actor]:
	var result = []
	var distance_data = calculate_distances(center, radius, Vector2i(0, 0))
	var distance_map = distance_data["distance_map"]
	for actor in actors.keys():
		var pos = actors[actor]
		if distance_map.has(pos) and distance_map[pos] <= radius:
			result.append(actor)
	return result

# Method to get actors in a square area
func get_actors_in_square(top_left: Vector2i, bottom_right: Vector2i) -> Array[Actor]:
	var result = []
	for actor in actors.keys():
		var pos = actors[actor]
		if pos.x >= top_left.x and pos.x <= bottom_right.x and pos.y >= top_left.y and pos.y <= bottom_right.y:
			result.append(actor)
	return result

# Method to get actors in an emanation
func get_actors_in_emanation(center: Vector2i, size: Vector2i, radius: int) -> Array[Actor]:
	var result = []
	var distance_data = calculate_distances(center, radius, size)
	var distance_map = distance_data["distance_map"]
	for actor in actors.keys():
		var pos = actors[actor]
		if distance_map.has(pos) and distance_map[pos] <= radius:
			result.append(actor)
	return result

# Method to get the shortest walking path to a target position
func get_shortest_path(start: Vector2i, target: Vector2i) -> Array[Vector2i]:
	return get_simple_path(to_world(start), to_world(target)).map(to_cell)

# Placeholder method for getting a simple path
func get_simple_path(start: Vector2, target: Vector2) -> Array[Vector2]:
	# Replace this with your actual pathfinding logic
	return [start, target]

# Method to get walking distance considering pathfinder rules
func get_walking_distance(start: Vector2i, target: Vector2i, path: Array[Vector2i] = []) -> int:
	# First, calculate the distance for the provided path
	var distance = 0
	for i in range(1, path.size()):
		distance += calculate_step_distance(path[i - 1], path[i], true)

	# Then, continue from the last point in the path to the target
	var last_point = start
	if path.size() > 0:
		last_point = path[path.size() - 1]

	return distance + calculate_step_distance(last_point, target, true)

# Helper method to calculate step distance considering diagonal rules and terrain costs
func calculate_step_distance(start: Vector2i, target: Vector2i, consider_terrain: bool = false) -> int:
	var dx = abs(target.x - start.x)
	var dy = abs(target.y - start.y)
	var distance = 0
	if consider_terrain:
		var base_distance = 1
		if dx == 1 and dy == 1:
			base_distance = 2  # Diagonal movement cost
		distance = base_distance * get_tile_cost(target)
	else:
		var diagonals = min(dx, dy)
		distance += diagonals * 2
		distance += abs(dx - dy)
	return distance

# Method to get tile cost based on terrain
func get_tile_cost(cell: Vector2i) -> int:
	var tile_id = tilemap_source.get_cell_source_id(0, cell)
	# Define your terrain costs here
	match tile_id:
		1:
			return float('inf')  # Impassable
		2:
			return 2  # Difficult terrain
		3:
			return 4  # Greater difficult terrain
		_:
			return 1  # Normal terrain

# Method to get actors in an area
func get_actors_in_area(center: Vector2i, size: Vector2i, area: Array[Vector2i]) -> Array[Actor]:
	var result = []
	for actor in actors.keys():
		var actor_pos = actors[actor]
		for offset in area:
			if actor_pos == center + offset:
				result.append(actor)
				break
	return result

func get_emanation(center: Vector2i, size: Vector2i, radius: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var distance_data = calculate_distances(center, radius, size)
	var distance_map = distance_data["distance_map"]
	for pos in distance_map.keys():
		if distance_map[pos] <= radius:
			result.append(pos)
	return result

# Helper method to perform BFS and calculate distances using a priority queue
func calculate_distances(start: Vector2i, max_distance: int = 10, footprint: Vector2i = Vector2i(0, 0), consider_terrain: bool = false) -> Dictionary:
	var distance_map = {}
	var inverse_distance_map = {}

	# Priority queue with (distance, position) tuples
	var queue = PriorityQueue.new()
	var initial_positions = get_initial_positions(start, footprint)
	for pos in initial_positions:
		queue.push(0, pos)
		distance_map[pos] = 0
		if not inverse_distance_map.has(0):
			inverse_distance_map[0] = [pos]
		else:
			inverse_distance_map[0].append(pos)

	while not queue.empty():
		var current = queue.pop()
		var current_distance = distance_map[current]

		if current_distance < max_distance:
			for neighbor in get_adjacent_cells(current):
				var step_distance = calculate_step_distance(current, neighbor, consider_terrain)
				var new_distance = current_distance + step_distance
				if not distance_map.has(neighbor) or new_distance < distance_map[neighbor]:
					distance_map[neighbor] = new_distance
					if not inverse_distance_map.has(new_distance):
						inverse_distance_map[new_distance] = [neighbor]
					else:
						inverse_distance_map[new_distance].append(neighbor)
					queue.push(new_distance, neighbor)

	return {"distance_map": distance_map, "inverse_distance_map": inverse_distance_map}

# Helper method to get initial positions based on the footprint
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
