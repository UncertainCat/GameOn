extends ActionCard

class_name StrideActionCard

# Override _init to set specific values for StrideAction
func _init():
	super._init(
		"Stride",
		"You move up to your Speed.",
		Action.ActionType.ONE,
		"No requirements",
		[]
	)

func create_stride_action(actor: Actor) -> Action:
	var action = Action.new(
		self.command_controller,
		self.action_name,
		self.action_type,
		self.requirements,
		self.description,
		actor,
		self.effects,
	)
	action.game_steps = func game_steps(combat_manager: CombatManager) -> Array:
		var start_path = [combat_manager.current_battle_map.get_unit_position(actor)]
		var steps = []
		steps.append(WalkStep.new(start_path, action, actor))
		return steps
	return action
