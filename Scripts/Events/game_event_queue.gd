extends Node

class_name GameEventQueue

# Singleton instance
var instance: GameEventQueue = null

# Dictionary to store event listeners
var listeners: Dictionary = {}

# Queue to store events
var event_queue: Array = []

# Initialize the singleton
func _init():
	if instance == null:
		instance = self

# Register a listener for a specific event type
func register_listener(event_type: String, callback: Callable):
	if not listeners.has(event_type):
		listeners[event_type] = []
	listeners[event_type].append(callback)

# Add an event to the queue
func add_event(event: GameEvent):
	event_queue.append(event)
	_process_events()

# Process events in the queue
func _process_events():
	if event_queue.is_empty():
		return
	
	var event = event_queue.pop_front()
	_handle_event(event)

# Handle an individual event
func _handle_event(event: GameEvent) -> void:
	var event_type = event.get_register()
	print("handling event: ", listeners)
	var tasks = []
	for listener in listeners[event_type]:
		tasks.append(_run_listener(listener, event))

	# Wait for all listeners to finish before processing the next event
	_process_tasks(tasks)

# Process all tasks and wait for completion
func _process_tasks(tasks: Array):
	for task in tasks:
		await task
	_process_events()

# Run a listener method
func _run_listener(listener: Callable, event: GameEvent):
	listener.call_deferred(event)
