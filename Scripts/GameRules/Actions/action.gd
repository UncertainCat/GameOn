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
var command_controller: CommandController

func _init(command_controller: CommandController, action_name: String, action_type: ActionType, requirements: String, description: String, actor: Actor, effects: Array = []):
	self.action_name = action_name
	self.action_type = action_type
	self.requirements = requirements
	self.description = description
	self.actor = actor
	self.effects = effects
	self.command_controller = command_controller

# Method to describe the action
func describe() -> String:
	return "Action: %s\nType: %s\nRequirements: %s\nDescription: %s\nEffects: %s" % [
		action_name,
		action_type,
		requirements,
		description,
		effects
	]

func preview(combat_controller: CombatController):
	print("preview is unimplemented!")

# Use the passed game_steps function
func game_steps(combat_manager: CombatManager) -> Array:
	push_error("game_steps method not provided!")
	return []
