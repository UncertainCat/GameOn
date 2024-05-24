extends Node2D

class_name CombatController

# Declare member variables here
var selected_unit = null
var current_action = null
var action_history = []

# GUI Components
@onready var initiative_carousel = $InitiativeCarousel
#onready var available_actions_panel = $AvailableActionsPanel

func _ready():
	set_process(true)
	_initialize_gui()
	_select_default_unit_if_none()

func _initialize_gui():
	# Initialize the GUI components
	initiative_carousel.setup()
	# available_actions_panel.setup()
	# chat_log.setup()

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
		if unit and combat_manager.is_pc_unit(unit):
			select_unit(unit)
		elif current_action:
			if validate_action(current_action, cell):
				perform_action(current_action, cell)
				current_action = null
			else:
				print("Invalid action")
		elif selected_unit:
			if validate_action("stride", cell):
				perform_action("stride", cell)
			else:
				print("Invalid default action")
		elif unit:
			select_unit(unit)
		else:
			print("No unit selected and no action to perform")

func select_unit(unit):
	selected_unit = unit
	current_action = null
	update_ui_for_selected_unit(unit)
	print("unit selected: ", unit)

func update_ui_for_selected_unit(unit):
	# Update UI to reflect the selected unit's actions and stats
	pass

func validate_action(action, target):
	return combat_manager.validate_action(selected_unit, action, target)

func select_action(action):
	if selected_unit:
		current_action = action
		print("action selected: ", action)
	else:
		print("No unit selected to perform action")

func perform_action(action, target):
	if validate_action(action, target):
		selected_unit.perform_action(action, target)
	else:
		print("Invalid action or no unit selected.")

# Signal Handlers
func _on_initiative_updated(new_order):
	initiative_carousel.update_order(new_order)

func _on_action_performed(actor, action, target):
	action_history.append({"unit": actor, "action": action, "target": target})
	print("Action performed by %s: %s on %s" % [actor.name, action, target])

func _select_default_unit_if_none():
	if not selected_unit:
		selected_unit = combat_manager.get_first_pc_unit()
		if selected_unit:
			update_ui_for_selected_unit(selected_unit)
			print("Default unit selected: ", selected_unit)
		else:
			print("No PC units available for selection.")
