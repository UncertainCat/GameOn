extends Node

class_name EventBus

signal event_published(event)
signal event_completed(event)

var event_queue: Array = []
var is_processing: bool = false
var actors: Dictionary = {}

func register_actor(actor_id: int, actor: Node):
	actors[actor_id] = actor

func publish_event(event: Event):
	event_queue.append(event)
	_process_next_event()

func _process_next_event() -> void:
	if is_processing or event_queue.is_empty():
		return

	var event = event_queue.pop_front()
	is_processing = true
	emit_signal("event_published", event)

	if actors.has(event.target_actor_id):
		var actor = actors[event.target_actor_id]
		actor.handle_event(event)
	else:
		print("Actor with ID %d not found" % event.target_actor_id)

	if event.non_blocking:
		is_processing = false
		_process_next_event()
	else:
		_wait_for_completion(event)

func _wait_for_completion(event: Event) -> void:
	var timer = Timer.new()
	timer.wait_time = event.timeout
	timer.one_shot = true
	add_child(timer)
	timer.start()

	await timer.timeout
	if is_processing:
		print("Event timed out: %s" % event.type)
		is_processing = false
		_process_next_event()

func complete_event(event: Event):
	if is_processing:
		emit_signal("event_completed", event)
		is_processing = false
		_process_next_event()
