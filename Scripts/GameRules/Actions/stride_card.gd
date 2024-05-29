extends ActionCard

class_name StrideActionCard

# Override _init to set specific values for StrideAction
func _init():
	self.action_name = "Stride"
	self.description = "You move up to your Speed."
	self.action_type = Action.ActionType.ONE
	self.requirements = ""

func create_stride_action(actor: Actor) -> Action:
	var start_path: Array[Vector2i] = [combat_manager.get_unit_position(actor)]
	var steps: Array[GameStep] = []
	steps.append(WalkStep.new(start_path, actor))
	return Action.new(
		self.action_name,
		self.action_type,
		self.requirements,
		self.description,
		actor,
		steps,
	)
