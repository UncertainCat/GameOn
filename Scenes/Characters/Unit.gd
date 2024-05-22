extends Resource

class_name Unit

# The StatSheet containing the core stats
var stat_sheet: StatSheet

# Additional unit-specific information
var name: String
var unit_type: String  # e.g., "PC", "NPC", "Monster"
var level: int
var abilities: Array

# Initialize with default values
func _init():
	stat_sheet = StatSheet.new()
	name = ""
	unit_type = ""
	level = 1
	abilities = []
