extends Node2D

class_name CombatManager

var initiative_queue: Array[Actor] = []
var current_steps: Array[GameStep] = []
var game_step_listeners: Dictionary = {} # Dictionary to hold listeners for specific game steps
var current_combatant: Actor = null
var current_battle_map: BattleMap
var pending_action_request: bool = false

func _ready():
	# Initialization logic if needed
	pass

# Method to populate combatants for the combat scenario
func populate_combat(battle_map: BattleMap, pcs: Array[Node2D], npcs: Array[Node2D]):
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

func action_requested(actor: Actor):
	pass

# Helper method to place actors
func _place_actors(battle_map: BattleMap, actors: Array[Node2D], spawn_points: Array[Vector2i], actor_type: String) -> bool:
	if actors.size() > spawn_points.size():
		push_error("Not enough %s spawn points for all %ss" % [actor_type, actor_type])
		return false
	for i in range(actors.size()):
		var actor = actors[i]
		var spawn_point = spawn_points[i]
		game_event_queue.add_event(SpawnActorGameEvent.new(actor, spawn_point))
		battle_map.add_actor(actor, spawn_point)
		initiative_queue.append(actor)
	return true

# Method to get a unit at a specific grid position
func get_unit_at(position: Vector2i) -> Node2D:
	return current_battle_map.get_actors_in_square(position, position).front()

func get_unit_position(actor: Node2D) -> Vector2i:
	return current_battle_map.get_actor_position(actor)

# Custom sort function for initiative
func _sort_by_initiative(a, b):
	return b["initiative"] - a["initiative"]

# Main loop for processing game steps
func process_steps(steps: Array[GameStep]):
	current_steps = steps
	while current_steps.size() > 0:
		var step: GameStep = current_steps.pop_front()
		var new_steps: Array[GameStep] = step.process(self)
		# Notify listeners
		if game_step_listeners.has(step.get_class()):
			for listener in game_step_listeners[step.get_class()]:
				process_steps(listener)

		# Insert new steps at the front of the queue
		current_steps = new_steps + current_steps

# Turn processing loop
func start_combat():
	# First, roll for initiative
	
	process_steps([RollForInitiativeStep.new()])
	
	# Start turn processing
	while initiative_queue.size() > 0:
		var current_combatant = initiative_queue.pop_front()
		var turn_began_step = TurnBeganStep.new(current_combatant)
		process_steps([turn_began_step])

		while true:
			pending_action_request = true
			var next_action = await command_controller.next_action(current_combatant)
			pending_action_request = false
			if next_action == null:
				var turn_ended_step = TurnEndedStep.new(current_combatant)
				process_steps([turn_ended_step])
				break
			else:
				var action_start_step: GameStep = ActionStartStep.new(next_action)
				var action_end_step: GameStep = ActionEndStep.new(next_action)
				var action_steps: Array[GameStep] = next_action.game_steps
				action_steps.push_front(action_start_step)
				action_steps.push_back(action_end_step)
				process_steps(action_steps)

# Function to register a listener for a specific game step
func register_game_step_listener(step_class: String, listener: Array[GameStep]):
	if not game_step_listeners.has(step_class):
		game_step_listeners[step_class] = []
	game_step_listeners[step_class].append(listener)
	
# Function to roll a dice (for simplicity)
func roll_dice(sides: int) -> int:
	return randi() % sides + 1

# Function to get all combatants (placeholder)
func get_combatants() -> Array[Actor]:
	# Implement this based on your game's logic
	return []


class RollForInitiativeStep extends GameStep:
	var initiative_order: Array
	func process(combat_manager: CombatManager) -> Array[GameStep]:
		# Process the initiative rolled logic
		# Do nothing for now
		return []

class TurnBeganStep extends GameStep:
	var actor: Actor
	func _init(actor):
		self.actor = actor
	func process(combat_manager: CombatManager) -> Array[GameStep]:
		# Logic for beginning of a turn
		return []

class TurnEndedStep extends GameStep:
	var actor: Actor
	func _init(actor):
		self.actor = actor
	func process(combat_manager: CombatManager) -> Array[GameStep]:
		# Logic for end of a turn
		return []

class ActionStartStep extends GameStep:
	var action: Action
	func _init(action):
		self.action = action
	func process(combat_manager: CombatManager) -> Array[GameStep]:
		# Logic for starting an action
		return []

class ActionEndStep extends GameStep:
	var action: Action
	func _init(action):
		self.action = action
	func process(combat_manager: CombatManager) -> Array[GameStep]:
		# Logic for ending an action
		return []
