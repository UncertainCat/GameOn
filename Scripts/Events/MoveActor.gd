extends GameEvent

class_name MoveActorGameEvent

# Specific properties for this event
var from: Vector2i
var to: Vector2i

static func get_register() -> String:
	return "MoveActorGameEvent"

func _init(from: Vector2i, to: Vector2i):
	self.from = from
	self.to = to
