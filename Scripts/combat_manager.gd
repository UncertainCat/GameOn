extends Node

class_name CombatManager

# Property to track the current battle map
var current_battle_map: BattleMap

# Method to start a new combat
func start_combat(battle_map: BattleMap, pcs: Array[Node2D], npcs: Array[Node2D]):
	# Track the current battle map
	current_battle_map = battle_map
	
	# Get the spawn points from the battle map
	var spawn_points = battle_map.get_spawn_points()
	
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
	return true
