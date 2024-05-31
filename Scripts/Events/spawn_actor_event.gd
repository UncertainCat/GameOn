extends GameEvent

class_name SpawnActorGameEvent

# Specific properties for this event
var cell: Vector2i
var actor: Actor

static func get_register() -> String:
	return "SpawnActorGameEvent"

func _init(actor: Actor, cell: Vector2i):
	self.cell = cell
	self.actor = actor
