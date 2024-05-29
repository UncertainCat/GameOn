extends GameStep

class_name WalkStep

var from_path: Array[Vector2i]
var distance_walked: int
var stride: Action
var actor: Actor

func _init(from_path: Array[Vector2i], stride: Action, actor: Actor):
	self.from_path = from_path
	self.stride = stride
	self.actor = actor

func process(combat_manager: CombatManager) -> Array[GameStep]:
	var map = combat_manager.current_battle_map
	if actor.can_walk() == false:
		return []
	var speed = actor.evaluate_walk_speed()
	var to_square = command_controller.request_next_walk_cell(actor, from_path, speed)
	if from_path.count(to_square) > 0:
		return []
	if map.is_tile_impassable(to_square):
		return []
	var distance = map.get_walking_distance(to_square, from_path, true)
	if distance > speed:
		print("Error: Attempted movement greater than speed")
		return []
	var keep_walking = true
	if distance == speed:
		keep_walking = false
	var exit_step = LeaveSquareStep.new(self.from_square)
	var enter_step = EnterSquareStep.new(self.to_square)
	var new_path = from_path
	new_path.append(to_square)
	var next_steps = [exit_step, enter_step]
	if next_steps:
		next_steps.append(WalkStep.new(new_path, stride, actor))
	return next_steps

