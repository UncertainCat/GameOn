extends Node

class_name ActionDefinitions

# Enumerations for action types
enum ActionType {
	ONE,
	TWO,
	THREE,
	REACTION,
	FREE
}

# Define actions as dictionaries
var ACTIONS = {
	"stride": {
		"action_name": "Stride",
		"action_type": ActionType.ONE,
		"cost": 1,
		"requirements": "Must have a valid path to the destination",
		"description": "Move to a new position on the battlefield",
		"effects": ["Change position"]
	},
	"attack": {
		"action_name": "Attack",
		"action_type": ActionType.ONE,
		"cost": 1,
		"requirements": "Must have a target in range",
		"description": "Perform a basic attack on the target",
		"effects": ["Deal damage"]
	}
	# Add more actions as needed...
}
