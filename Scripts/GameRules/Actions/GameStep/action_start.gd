extends GameStep

class_name ActionStart

var action: Action

func _init(action: Action):
	self.action = action

func process(combat_manager: CombatManager) -> Array[GameStep]:
	print("Action started: %s" % action.action_name)
	return []
