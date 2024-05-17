# Event.gd
extends RefCounted

class_name Event

var type: String
var target_actor_id: int
var non_blocking: bool = false
var timeout: float = 5.0  # Default timeout in seconds
var data: Dictionary = {}

func _init(_type: String, _target_actor_id: int, _data: Dictionary = {}, _non_blocking: bool = false, _timeout: float = 5.0):
	type = _type
	target_actor_id = _target_actor_id
	data = _data
	non_blocking = _non_blocking
	timeout = _timeout
