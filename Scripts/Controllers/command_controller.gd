extends Node2D

class_name CommandController

var current_path: Array[Vector2i] = []
var actor: Actor = null

func preview_card(actor: Actor, action_card: ActionCard, preview_cell: Vector2i):
	if action_card is StrideActionCard:
		preview_stride_action(actor, preview_cell)
	else:
		print("Preview not implemented for this type of action card")

func execute_card(actor: Actor, action_card: ActionCard, target_cell: Vector2i):
	if action_card is StrideActionCard:
		execute_stride_action(actor, target_cell)
	else:
		# Default handling for unrecognized action card types
		print("Execute not implemented for this type of action card")

# Preview the possible movement for stride actions
func preview_stride_action(actor: Actor, target_cell: Vector2i):
	var mouse_position = get_global_mouse_position()
	var mouse_cell = combat_manager.current_battle_map.to_cell(mouse_position)
	var speed = actor.evaluate_walk_speed()
	var start_position = combat_manager.current_battle_map.get_actor_position(actor)
	var possible_moves: Array[Vector2i] = combat_manager.current_battle_map.get_emanation(start_position, Vector2i.ZERO, speed, true)
	var highlighted_path = []

	# Highlight all possible moves with a lower opacity
	for move in possible_moves:
		combat_manager.current_battle_map.highlight_tile(move, 0.5)

	# Check if the mouse is over a possible move and calculate the path to it
	if possible_moves.has(mouse_cell):
		highlighted_path = combat_manager.current_battle_map.get_shortest_path(start_position, mouse_cell)
		current_path = highlighted_path

		# Highlight the path to the mouse position with a brighter highlight
		for cell in highlighted_path:
			combat_manager.current_battle_map.highlight_tile(cell, 1.0)

	return highlighted_path

# Confirm the path selection and execute the stride action
func execute_stride_action(actor, target_cell):
	add_step_to_path(actor, target_cell)
	var action = StrideActionCard.new().create_stride_action(actor)

# Utility to add a new step to the path
func add_step_to_path(actor: Actor, cell: Vector2i):
	current_path.append(cell)
	if current_path.size() > actor.evaluate_walk_speed():
		print("Path exceeds maximum movement speed")
		current_path.pop_back()

func preview_path():
	for cell in current_path:
		combat_manager.current_battle_map.highlight_tile(cell, 1.0)
