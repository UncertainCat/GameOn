extends Node

class_name GameStep

# Method to be overridden by subclasses
func process(combat_manager: CombatManager) -> Array[GameStep]:
	return []

