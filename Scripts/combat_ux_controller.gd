extends Node2D

class_name CombatUxController

var selected_unit: Actor = null
var current_action: ActionCard = null

func _ready():
	set_process(true)

func _process(_delta):
	var battle_map = combat_manager.current_battle_map
	if battle_map == null:
		print("No active battle map found!")
		return
	if not selected_unit:
		return
	var mouse_pos = get_global_mouse_position()
	var cell = battle_map.to_cell(mouse_pos)
	if not current_action:
		command_controller.preview_card(selected_unit, default_action(selected_unit), cell)
	else:
		command_controller.preview_card(selected_unit, current_action, cell)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_left_click()

func _on_left_click():
	var battle_map = combat_manager.current_battle_map
	if not battle_map:
		print("No active battle map found!")
		return

	var cell = battle_map.to_cell(get_global_mouse_position())
	var clicked_unit = combat_manager.get_unit_at(cell)
	if clicked_unit:
		if not clicked_unit == selected_unit:
			print("Unit selected: ", clicked_unit, " at: ", cell)
			select_unit(clicked_unit)
	elif not selected_unit == null:
		if command_controller.awaiting_command and command_controller.actor == selected_unit:
			command_controller.select_movement(selected_unit, cell)
		if current_action == null:
			command_controller.select_action(selected_unit, default_action(selected_unit), cell)
		else:
			command_controller.select_action(selected_unit, current_action, cell)

func select_unit(unit):
	selected_unit = unit
	current_action = null
	print("Unit selected: ", unit)

func default_action(unit: Actor) -> ActionCard:
	for card in unit.action_cards:
		if card is StrideActionCard:
			return card
	# Assume every unit must have a stride action, create if not found
	var new_card = StrideActionCard.new()
	unit.action_cards.append(new_card)
	return new_card

func select_action(action):
	if selected_unit:
		current_action = action
		print("Action selected: ", action)
	else:
		print("No unit selected to perform action")
