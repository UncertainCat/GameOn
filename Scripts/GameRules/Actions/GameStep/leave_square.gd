extends GameStep

class_name LeaveSquareStep

var square: Vector2i

func _init(square: Vector2i):
	self.square = square

func process(combat_manager: CombatManager) -> Array[GameStep]:
	print("Leaving square: %s" % str(square))
	return []
