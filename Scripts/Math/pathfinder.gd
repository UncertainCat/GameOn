class_name Dijkstra

extends Node

# Use a string representation of Vector2i for dictionary keys
func vec2i_to_str(vec):
	return str(vec.x) + "," + str(vec.y)

# Method to calculate distances using Dijkstra's algorithm
func calculate_distances(
	start: Vector2i,
	max_distance: int,
	initial_positions: Array,
	get_neighbors_func: Callable,
	calculate_distance_func: Callable
) -> Dictionary:
	var distance_map = {}
	var inverse_distance_map = {}
	var queue = PriorityQueue.new()
	var checked_nodes = {}  # Dictionary to keep track of checked nodes
	var path_map = {}  # Dictionary to track the path to each node

	# Initialize distances and paths for initial positions
	for pos in initial_positions:
		var initial_path = [start, pos]  # Starting path includes the start and the position
		queue.push(0, initial_path)
		distance_map[pos] = 0
		path_map[pos] = initial_path
		if not inverse_distance_map.has(0):
			inverse_distance_map[0] = [pos]
		else:
			inverse_distance_map[0].append(pos)

	# Process the queue
	while not queue.empty():
		var current_path = queue.pop()
		var current_node = current_path[-1]

		# Skip processing if the node is already checked
		if checked_nodes.has(vec2i_to_str(current_node)):
			continue
		checked_nodes[vec2i_to_str(current_node)] = true

		for neighbor in get_neighbors_func.call(current_node):
			var new_path = current_path + [neighbor]
			var new_distance = calculate_distance_func.call(new_path)  # Use full path to calculate distance
			if new_distance <= max_distance:
				if not distance_map.has(neighbor) or new_distance < distance_map[neighbor]:
					distance_map[neighbor] = new_distance
					path_map[neighbor] = new_path  # Update path to this neighbor
					if not inverse_distance_map.has(new_distance):
						inverse_distance_map[new_distance] = [neighbor]
					else:
						inverse_distance_map[new_distance].append(neighbor)
					queue.push(new_distance, new_path)
			else:
				checked_nodes[vec2i_to_str(neighbor)] = true

	return {"distance_map": distance_map, "inverse_distance_map": inverse_distance_map}


func calculate_shortest_path(
	start: Vector2i,
	target: Vector2i,
	get_neighbors_func: Callable,
	calculate_distance_func: Callable
) -> Array:
	var distance_map = {}
	var queue = PriorityQueue.new()
	var came_from = {}  # Tracks where each node was reached from

	# Initialize
	queue.push(0, [start])  # Start with a path that only includes the starting point
	distance_map[vec2i_to_str(start)] = 0
	came_from[vec2i_to_str(start)] = null  # No preceding node for the start

	while not queue.empty():
		var current_path = queue.pop()
		var current_node = current_path[-1]

		# If the target is reached, reconstruct and return the path
		if current_node == target:
			return reconstruct_path(came_from, start, target)

		# Process each neighbor
		for neighbor in get_neighbors_func.call(current_node):
			var new_path = current_path + [neighbor]
			var new_distance = calculate_distance_func.call(new_path)

			# Update if the neighbor has not been visited or found via a shorter path
			if not distance_map.has(vec2i_to_str(neighbor)) or new_distance < distance_map[vec2i_to_str(neighbor)]:
				queue.push(new_distance, new_path)
				distance_map[vec2i_to_str(neighbor)] = new_distance
				came_from[vec2i_to_str(neighbor)] = current_node

	return []  # Return empty if no path is found

# Helper method to reconstruct the path from start to target
func reconstruct_path(came_from, start: Vector2i, target: Vector2i) -> Array:
	var path = []
	var current = target
	while current != null:
		path.append(current)
		current = came_from[vec2i_to_str(current)]
	path.reverse()  # Reverse to get the path from start to target
	return path
