extends Node2D

class_name WalkController

signal walk_completed

class Walk:
	var actor: Actor
	var path: Array[Vector2i]
	var action: Action

	func _init(actor: Actor, path: Array[Vector2i], action: Action):
		self.actor = actor
		self.path = path
		self.action = action

var walks: Dictionary = {}

func start_walk(actor: Actor, action_card: StrideActionCard, target_cell: Vector2i):
	var actor_cell = combat_manager.get_unit_position(actor)
	var path = combat_manager.current_battle_map.get_shortest_walking_path(actor_cell, target_cell)
	if not path.is_empty():
		path.pop_front() # Remove the start cell
		var action = action_card.create_stride_action(actor)
		var walk = Walk.new(actor, path, action)
		walks[action] = walk
		return action
	else:
		emit_signal("walk_completed", action_card.create_stride_action(actor))
		return null

func next_walk_cell(actor: Actor, from_path: Array[Vector2i], speed: int) -> Vector2i:
	var walk = get_current_walk(actor)
	if walk != null and walk.path.size() > 0:
		return walk.path.pop_front()
	else:
		if walk != null:
			walks.erase(walk.action)
		return combat_manager.get_unit_position(actor)

func get_current_walk(actor: Actor) -> Walk:
	for walk in walks.values():
		if walk.actor == actor:
			return walk
	return null

func preview_stride_action(actor: Actor, target_cell: Vector2i, speed: int):
	var map = combat_manager.current_battle_map
	var mouse_position = get_global_mouse_position()
	var mouse_cell = map.to_cell(mouse_position)
	var start_position = map.get_actor_position(actor)

	var possible_moves: Array[Vector2i] = map.get_emanation(start_position, Vector2i.ZERO, speed, true)

	var highlighted_path = []
	# Highlight all possible moves with a lower opacity
	for move in possible_moves:
		combat_manager.current_battle_map.highlight_tile(move, 0.2)

	# Check if the mouse is over a possible move and calculate the path to it
	if possible_moves.has(mouse_cell):
		highlighted_path = combat_manager.current_battle_map.get_shortest_walking_path(start_position, mouse_cell)

		# Highlight the path to the mouse position with a brighter highlight
		for cell in highlighted_path:
			combat_manager.current_battle_map.highlight_tile(cell, 1.0)

	return highlighted_path

func clear_previews():
	# Implement logic to clear the current previews
	pass
