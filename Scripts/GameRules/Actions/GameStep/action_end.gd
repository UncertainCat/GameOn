extends GameStep

class_name ActionEnd

var action: Action

func _init(action: Action):
	self.action = action

func process(combat_manager: CombatManager) -> Array[GameStep]:
	print("Action ended: %s" % action.action_name)
	return []
