extends Node2D

class_name CommandController

signal action_selected
signal move_selected

var current_path: Array[Vector2i] = []
var walked_tiles: Array[Vector2i] = []
var actor: Actor = null
var awaiting_action: bool = false
var action_result = null

var selected_card: ActionCard
var target_cell: Vector2i

var awaiting_movement: bool = false

# The next_action method that waits for an action command
func next_action(actor: Actor) -> Action:
	print("Awaiting an action")
	self.walked_tiles = []
	self.current_path = []
	self.actor = actor
	awaiting_action = true
	await action_selected
	awaiting_action = false
	var action = build_card(actor, selected_card, target_cell)
	return action

func next_walk_cell(actor: Actor, from_path: Array[Vector2i], speed: int) -> Vector2i:
	if not current_path.is_empty():
		return current_path.pop_front()
	self.actor = actor
	awaiting_movement = true
	await move_selected
	awaiting_movement = false
	return current_path.pop_front()


# Method to preview the card
func preview_card(actor: Actor, action_card: ActionCard, preview_cell: Vector2i):
	if action_card is StrideActionCard and (awaiting_action or awaiting_movement):
		var speed = actor.evaluate_walk_speed()
		preview_stride_action(actor, preview_cell, speed)
	else:
		print("Preview not implemented for this type of action card")

# Method to build the action from the card
func build_card(actor: Actor, action_card: ActionCard, target_cell: Vector2i) -> Action:
	print("Building an action for ", actor, " Action: ", action_card.action_name, " at: ", target_cell)
	if action_card is StrideActionCard:
		var actor_cell = combat_manager.get_unit_position(actor)
		self.current_path = combat_manager.current_battle_map.get_shortest_walking_path(actor_cell, target_cell)
		self.current_path.pop_front()
		return StrideActionCard.new().create_stride_action(actor)
	else:
		print("build not implemented for this type of action card: ", action_card)
		return null

# Preview the possible movement for stride actions
func preview_stride_action(actor: Actor, target_cell: Vector2i, speed: int):
	var map = combat_manager.current_battle_map
	var mouse_position = get_global_mouse_position()
	var mouse_cell = map.to_cell(mouse_position)
	var start_position = map.get_actor_position(actor)
	
	var possible_moves: Array[Vector2i] = map.get_emanation(start_position, Vector2i.ZERO, speed, true, walked_tiles)
	
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


# Preview the current path
func preview_path():
	for cell in current_path:
		combat_manager.current_battle_map.highlight_tile(cell, 1.0)

# Trigger the action selected signal
func select_action(actor: Actor, action_card: ActionCard, target_cell: Vector2i):
	if awaiting_action and self.actor == actor:
		self.selected_card = action_card
		self.target_cell = target_cell
		emit_signal("action_selected")

func select_movement(actor: Actor, target_cell: Vector2i):
	if awaiting_movement and self.actor == actor:
		var actor_cell = combat_manager.get_unit_position(actor)
		self.current_path = combat_manager.current_battle_map.get_shortest_walking_path(actor_cell, target_cell)
		emit_signal("move_selected")
		
# Dummy method to get the current action card
# In a real implementation, this should get the actual action card selected by the player
func get_current_action_card() -> ActionCard:
	return StrideActionCard.new()
