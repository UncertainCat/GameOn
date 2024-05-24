extends Action

class_name StrideAction

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
	
func preview(combat_controller: CombatController):
	print("preview is unimplemented!")
	
func game_steps(combat_manager: CombatManager) -> Array:
	var steps = []
	var path = calculate_path(combat_manager)
	
	for square in path:
		steps.append(EnterSquareStep.new(square))
		steps.append(ExitSquareStep.new(square))
		
	return steps

# Placeholder for path calculation, to be implemented
func calculate_path(combat_manager: CombatManager) -> Array:
	# Return a list of squares (Vector2i) to be traversed
	return []
