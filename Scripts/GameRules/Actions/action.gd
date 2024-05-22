extends Node

class_name Action

# Reference the ActionType enum from ActionDefinitions
const ActionType = ActionDefinitions.ActionType

# Core properties for an action
var action_name: String
var action_type: ActionType
var cost: int
var requirements: String
var description: String
var effects: Array

func _init(action_data: Dictionary):
	self.action_name = action_data.get("action_name", "")
	self.action_type = action_data.get("action_type", ActionType.ONE)
	self.cost = action_data.get("cost", 1)
	self.requirements = action_data.get("requirements", "")
	self.description = action_data.get("description", "")
	self.effects = action_data.get("effects", [])

# Method to describe the action
func describe() -> String:
	return "Action: %s\nType: %s\nCost: %d\nRequirements: %s\nDescription: %s\nEffects: %s" % [
		action_name,
		action_type,
		cost,
		requirements,
		description,
		effects
	]
