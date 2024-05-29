extends Node

class_name GameEvent

var completed: bool

func _init():
	completed = false

# Interface for events
static func get_register() -> String:
	return "GameEvent"

func complete():
	completed = true
	game_event_queue.complete_event(self)
