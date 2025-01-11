extends Node2D

class_name CommandController

signal action_selected

var walk_controller: WalkController = null
var actor: Actor = null
var awaiting_command: bool = false
var action_result = null

var selected_card: ActionCard
var target_cell: Vector2i

func _ready():
	walk_controller = WalkController.new()
	add_child(walk_controller)
	walk_controller.connect("walk_completed", _on_walk_completed)

func process_command(actor: Actor, target_cell: Vector2i):
	print("command received")

# The next_action method that waits for an action command
func next_action(actor: Actor) -> Action:
	print("Awaiting an action")
	self.actor = actor
	awaiting_command = true
	await action_selected
	awaiting_command = false
	var action = build_card(actor, selected_card, target_cell)
	return action

# Method to preview the card
func preview_card(actor: Actor, action_card: ActionCard, preview_cell: Vector2i):
	if action_card is StrideActionCard:
		var speed = actor.evaluate_walk_speed()
		walk_controller.clear_previews()
		walk_controller.preview_stride_action(actor, preview_cell, speed)
	else:
		print("Preview not implemented for this type of action card")

# Method to build the action from the card
func build_card(actor: Actor, action_card: ActionCard, target_cell: Vector2i) -> Action:
	print("Building an action for ", actor, " Action: ", action_card.action_name, " at: ", target_cell)
	if action_card is StrideActionCard:
		var action = walk_controller.start_walk(actor, action_card, target_cell)
		return action
	else:
		print("build not implemented for this type of action card: ", action_card)
		return null

# Trigger the action selected signal
func select_action(actor: Actor, action_card: ActionCard, target_cell: Vector2i):
	if awaiting_command and self.actor == actor:
		self.selected_card = action_card
		self.target_cell = target_cell
		emit_signal("action_selected")

func _on_walk_completed(action: Action):
	print("Walk completed for action: ", action)
	# Handle walk completion, e.g., update states, etc.

func select_movement(actor: Actor, target_cell: Vector2i):
	# Handle new movement selection
	var action_card = StrideActionCard.new()
	print("staring walk")
	var action = walk_controller.start_walk(actor, action_card, target_cell)
	return action

# Implement next_walk_cell to return the next cell in the path
func next_walk_cell(actor: Actor, from_path: Array[Vector2i], speed: int) -> Vector2i:
	return walk_controller.next_walk_cell(actor, from_path, speed)
