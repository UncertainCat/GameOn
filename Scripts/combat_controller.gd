extends Node2D

class_name CombatController

signal action_card_selected(action_card)
signal action_card_activated(action_card, target_cell)

# Declare member variables here
var selected_unit = null
var current_action: ActionCard
var default_movement: ActionCard

func _ready():
	default_movement = StrideActionCard.new()
	set_process(true)

func _process(_delta):
	var battle_map = combat_manager.current_battle_map
	if battle_map:
		var mouse_pos = get_global_mouse_position()
		var cell = battle_map.to_cell(mouse_pos)
		cell = Vector2i(floor(cell.x), floor(cell.y))
		battle_map.highlight_tile(cell)
	else:
		print("No active battle map found!")

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_left_click()

func _on_left_click():
	var battle_map = combat_manager.current_battle_map
	if battle_map:
		var cell = battle_map.to_cell(get_global_mouse_position())
		var unit = combat_manager.get_unit_at(cell)
		if unit:
			if unit.controller == self:
				select_unit(unit)
			else:
				emit_signal("action_card_activated", current_action, cell)
		else:
			print("No unit selected and no action to perform")
	else:
		print("No active battle map found!")

func select_unit(unit):
	selected_unit = unit
	current_action = null
	print("unit selected: ", unit)

func select_action(action):
	if selected_unit:
		current_action = action
		emit_signal("action_card_selected", action)
		print("action selected: ", action)
	else:
		print("No unit selected to perform action")
