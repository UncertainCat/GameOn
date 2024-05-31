extends GameEvent

class_name SpawnActorGameEvent

# Specific properties for this event
var cell: Vector2i

static func get_register() -> String:
	return "SpawnActorGameEvent"

func _init(cell: Vector2i):
	self.cell = cell
