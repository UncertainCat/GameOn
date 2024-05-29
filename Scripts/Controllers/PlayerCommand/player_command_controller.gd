extends Node2D

class_name CommandController

# Declare member variables here
var preview_action: ActionCard

func _ready():
	set_process(true)

func _process(_delta):
	var battle_map = combat_manager.current_battle_map
	if battle_map:
		var mouse_pos = get_global_mouse_position()
		var cell = battle_map.to_cell(mouse_pos)
		cell = Vector2i(floor(cell.x), floor(cell.y))
		_preview_action(cell)
	else:
		print("No active battle map found!")

func _preview_action(cell):
	if preview_action:
		if combat_manager.is_valid_target(cell, preview_action):
			combat_manager.highlight_target(cell)
		else:
			combat_manager.clear_highlight()
	else:
		print("No action to preview")

func set_preview_action(action):
	preview_action = action
	print("Preview action set: ", action)
