extends Node

class_name Action

# Enumerations for action types
enum ActionType {
	ONE,
	TWO,
	THREE,
	REACTION,
	FREE
}

# Core properties for an action
var action_name: String
var action_type: ActionType
var requirements: String
var description: String
var actor: Actor
var effects: Array
var game_steps: Array[GameStep]

func _init(action_name: String, action_type: ActionType, requirements: String, description: String, actor: Actor, game_steps: Array[GameStep], effects: Array = []):
	self.action_name = action_name
	self.action_type = action_type
	self.requirements = requirements
	self.description = description
	self.actor = actor
	self.effects = effects
	self.game_steps = game_steps

# Method to describe the action
func describe() -> String:
	return "Action: %s\nType: %s\nRequirements: %s\nDescription: %s\nEffects: %s" % [
		action_name,
		action_type,
		requirements,
		description,
		effects
	]
