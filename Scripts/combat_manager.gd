extends Node

class_name CombatManager

# Property to track the current battle map
var current_battle_map: BattleMap

# Dictionaries to track units by their types and positions
var pc_units: Dictionary = {}
var npc_units: Dictionary = {}

# Signal to indicate an action has been performed
signal action_performed(actor: Node2D, action: String, target: Vector2i)

# Method to start a new combat
func start_combat(battle_map: BattleMap, pcs: Array[Node2D], npcs: Array[Node2D]):
	# Track the current battle map
	current_battle_map = battle_map
	
	# Get the spawn points from the battle map
	var spawn_points = battle_map.get_spawn_points()
	
	# Clear previous units
	pc_units.clear()
	npc_units.clear()
	
	# Check and place PCs
	if not _place_actors(battle_map, pcs, spawn_points.pc_spawn_points, "PC"):
		return
	
	# Check and place NPCs
	if not _place_actors(battle_map, npcs, spawn_points.npc_spawn_points, "NPC"):
		return

	print("Combat started with %d PCs and %d NPCs" % [pcs.size(), npcs.size()])

# Helper method to place actors
func _place_actors(battle_map: BattleMap, actors: Array[Node2D], spawn_points: Array, actor_type: String) -> bool:
	if actors.size() > spawn_points.size():
		push_error("Not enough %s spawn points for all %ss" % [actor_type, actor_type])
		return false
	
	for i in range(actors.size()):
		var actor = actors[i]
		var spawn_point = spawn_points[i]
		actor.position = battle_map.to_world(spawn_point.position)
		actor.target_grid_position = spawn_point.position
		
		# Track units by their grid position
		if actor_type == "PC":
			pc_units[spawn_point.position] = actor
		elif actor_type == "NPC":
			npc_units[spawn_point.position] = actor
	
	return true

# Method to get a unit at a specific grid position
func get_unit_at(position: Vector2i) -> Node2D:
	if pc_units.has(position):
		return pc_units[position]
	elif npc_units.has(position):
		return npc_units[position]
	return null

# Method to get the first PC unit
func get_first_pc_unit() -> Node2D:
	if pc_units.size() > 0:
		return pc_units.values()[0]
	return null

# Method to check if a unit is a PC
func is_pc_unit(unit: Node2D) -> bool:
	return pc_units.values().has(unit)

# Method to validate actions
func validate_action(unit: Node2D, action: String, target: Vector2i) -> bool:
	# Add custom logic to validate actions
	# This can include range checks, line of sight, etc.
	return true

# Method to perform actions
func perform_action(actor: Actor, action: String, target: Vector2i):
	if validate_action(actor, action, target):
		# Perform the action (the actual action logic should be implemented here)
		# For now, we just print the action
		print("%s performs %s on %s" % [actor.name, action, target])
		
		var move_event = MoveActorGameEvent.new(current_battle_map.to_cell(actor.position), target)
		game_event_queue.add_event(move_event)
	else:
		print("Invalid action or target")
