extends GameEvent

class_name MoveActorGameEvent

# Specific properties for this event
var from: Vector2i
var to: Vector2i
var actor: Actor

static func get_register() -> String:
	return "MoveActorGameEvent"

func _init(actor: Actor, from: Vector2i, to: Vector2i):
	self.actor = actor
	self.from = from
	self.to = to
