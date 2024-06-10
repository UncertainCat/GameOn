extends Node

class_name GameEventQueue

signal event_received(event: GameEvent)
signal event_processed(event: GameEvent)
signal listener_completed(event: GameEvent)

# Singleton instance
var instance: GameEventQueue = null

# Dictionary to store event listeners
var listeners: Dictionary = {}

# Queue to store events
var event_queue: Array = []

# Track the number of active listeners for the current event
var active_listeners: Array[Callable] = []

# Initialize the singleton
func _init():
	if instance == null:
		instance = self

# Register a listener for a specific event type
func register_listener(event_type: String, callback: Callable):
	if not listeners.has(event_type):
		listeners[event_type] = []
	print("registering:", event_type, " with: ", callback)
	listeners[event_type].append(callback)

# Add an event to the queue
func add_event(event: GameEvent):
	event_queue.append(event)
	_process_events()

# Process events in the queue
func _process_events():
	if event_queue.is_empty() or active_listeners.size() > 0:
		return
	var event = event_queue.pop_front()
	var event_type = event.get_register()
	if listeners.has(event_type):
		for callback in listeners[event_type]:
			active_listeners.append(callback)
			var on_complete = func ():
				active_listeners.erase(callback)
				_process_events()
			callback.call(on_complete, event)

# Handle listener completion
func _on_listener_completed(event: GameEvent):
	_process_events()

# Complete the event
func complete_event(event: GameEvent):
	emit_signal("listener_completed", event)

# Connect signals in the constructor
func _ready():
	connect("listener_completed", _on_listener_completed)
