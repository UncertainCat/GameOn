extends Node

class_name Pathfinder

# Placeholder for actual implementation
# You should replace these with your actual pathfinding methods and logic
func get_simple_path(start: Vector2, target: Vector2) -> Array[Vector2]:
	# Dummy path calculation
	return [start, target]

func get_emanation(center: Vector2i, size: Vector2i, radius: int) -> Array[Vector2i]:
	var emanation = []
	for x in range(center.x - radius, center.x + radius + 1):
		for y in range(center.y - radius, center.y + radius + 1):
			if (Vector2(x, y).distance_to(center) <= radius):
				emanation.append(Vector2i(x, y))
	return emanation

func get_walking_distance(start: Vector2i, target: Vector2i, path: Array[Vector2i] = []) -> int:
	# First, calculate the distance for the provided path
	var distance = 0
	for i in range(1, path.size()):
		distance += calculate_step_distance(path[i-1], path[i])
	
	# Then, continue from the last point in the path to the target
	if path.size() > 0:
		last_point = path[path.size() - 1]
	else:
		last_point = start
	
	return distance + calculate_step_distance(last_point, target)

func calculate_step_distance(start: Vector2i, target: Vector2i) -> int:
	dx = abs(target.x - start.x)
	dy = abs(target.y - start.y)
	return dx + dy + min(dx, dy)  # Simplified calculation, adjust for specific rules

func get_actors_in_area(center: Vector2i, size: Vector2i, area: Array[Vector2i], actors: Dictionary) -> Array[Actor]:
	var result = []
	for actor in actors.keys():
		var actor_pos = actors[actor]
		for offset in area:
			if (actor_pos == center + offset):
				result.append(actor)
				break
	return result
