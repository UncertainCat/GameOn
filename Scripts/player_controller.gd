extends Node2D

func _ready():
	set_process(true)

func _process(delta):
	var battle_map = combat_manager.current_battle_map
	if battle_map:
		var mouse_pos = get_global_mouse_position()
		var cell = battle_map.tilemap_source.local_to_map(mouse_pos)
		cell = Vector2i(floor(cell.x), floor(cell.y))
		battle_map.highlight_tile(cell)
	else:
		print("No active battle map found!")
