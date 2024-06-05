extends GameStep

class_name EnterSquareStep

var from_square: Vector2i
var to_square: Vector2i
var actor: Actor

func _init(actor: Actor, from_square: Vector2i, to_square: Vector2i):
	self.actor = actor
	self.from_square = from_square
	self.to_square = to_square

func process(combat_manager: CombatManager) -> Array[GameStep]:
	combat_manager.move_unit_position(actor, from_square, to_square)
	return []
