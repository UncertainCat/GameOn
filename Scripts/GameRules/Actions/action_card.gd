extends Node

class_name ActionCard

var action_name: String
var description: String
var action_type: Action.ActionType
var requirements: String
var effects: Array

func _init(action_name: String = "", description: String = "", action_type: Action.ActionType = Action.ActionType.ONE, requirements: String = "", effects: Array = []):
	self.action_name = action_name
	self.description = description
	self.action_type = action_type
	self.requirements = requirements
	self.effects = effects
