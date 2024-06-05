extends GameStep

class_name WalkStep

var from_path: Array[Vector2i]
var distance_walked: int
var actor: Actor

func _init(from_path: Array[Vector2i], actor: Actor, distance_walked: int = 0):
	self.from_path = from_path
	self.actor = actor
	self.distance_walked = distance_walked

func process(combat_manager: CombatManager) -> Array[GameStep]:
	var map = combat_manager.current_battle_map
	if actor.can_walk() == false:	
		return []
	var speed = actor.evaluate_walk_speed()
	var to_square = await command_controller.next_walk_cell(actor, from_path, speed)
	if from_path.count(to_square) > 0:
		return []
	if map.is_tile_impassable(to_square):
		return []
	var distance_walked = distance_walked + map.get_walking_distance(to_square, from_path, true)
	if distance_walked > speed:
		print("Error: Attempted movement greater than speed")
		return []
	var keep_walking = true
	if distance_walked == speed:
		keep_walking = false
	var exit_step = LeaveSquareStep.new(actor, combat_manager.get_unit_position(actor), to_square)
	var enter_step = EnterSquareStep.new(actor, combat_manager.get_unit_position(actor), to_square)
	var new_path = from_path
	new_path.append(to_square)
	var next_steps: Array[GameStep] = [exit_step, enter_step]
	if next_steps:
		next_steps.append(WalkStep.new(new_path, actor, distance_walked))
	return next_steps

