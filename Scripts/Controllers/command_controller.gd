extends Node2D

class_name CommandController

signal action_selected(action_card: ActionCard, target_cell: Vector2i)

var current_path: Array[Vector2i] = []
var actor: Actor = null
var awaiting_action: bool = false

func _ready():
	# Connect the action_selected signal to a method to handle the selected action
	connect("action_selected",_on_action_selected)

# The next_action method that waits for an action command
func next_action(actor: Actor) -> Action:
	self.actor = actor
	awaiting_action = true
	var action_result = await action_selected
	awaiting_action = false
	var action_card = action_result[0]
	var target_cell = action_result[1]
	execute_card(actor, action_card, target_cell)
	return action_card

# Signal handler for when an action is selected
func _on_action_selected(action_card: ActionCard, target_cell: Vector2i):
	if awaiting_action:
		emit_signal("action_selected", action_card, target_cell)

# Method to preview the card
func preview_card(actor: Actor, action_card: ActionCard, preview_cell: Vector2i):
	if action_card is StrideActionCard:
		preview_stride_action(actor, preview_cell)
	else:
		print("Preview not implemented for this type of action card")

# Method to execute the card
func execute_card(actor: Actor, action_card: ActionCard, target_cell: Vector2i):
	if action_card is StrideActionCard:
		execute_stride_action(actor, target_cell)
	else:
		print("Execute not implemented for this type of action card")

# Preview the possible movement for stride actions
func preview_stride_action(actor: Actor, target_cell: Vector2i):
	var mouse_position = get_global_mouse_position()
	var mouse_cell = combat_manager.current_battle_map.to_cell(mouse_position)
	var speed = actor.evaluate_walk_speed()
	var start_position = combat_manager.current_battle_map.get_actor_position(actor)
	var possible_moves: Array[Vector2i] = combat_manager.current_battle_map.get_emanation(start_position, Vector2i.ZERO, speed, true)
	var highlighted_path = []

	combat_manager.current_battle_map.clear_highlights()  # Clear previous highlights
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
func execute_stride_action(actor: Actor, target_cell: Vector2i):
	add_step_to_path(actor, target_cell)
	var action = StrideActionCard.new().create_stride_action(actor)

# Utility to add a new step to the path
func add_step_to_path(actor: Actor, cell: Vector2i):
	current_path.append(cell)
	if current_path.size() > actor.evaluate_walk_speed():
		print("Path exceeds maximum movement speed")
		current_path.pop_back()

# Preview the current path
func preview_path():
	for cell in current_path:
		combat_manager.current_battle_map.highlight_tile(cell, 1.0)

# Trigger the action selected signal
func select_action(action_card: ActionCard, target_cell: Vector2i):
	emit_signal("action_selected", action_card, target_cell)

# Dummy method to get the current action card
# In a real implementation, this should get the actual action card selected by the player
func get_current_action_card() -> ActionCard:
	return StrideActionCard.new()
