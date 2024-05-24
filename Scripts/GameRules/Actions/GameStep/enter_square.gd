extends GameStep

class_name EnterSquareStep

var square: Vector2i

func _init(square: Vector2i):
	self.square = square

func process(combat_manager: CombatManager) -> Array[GameStep]:
	print("Entering square: %s" % str(square))
	return []
