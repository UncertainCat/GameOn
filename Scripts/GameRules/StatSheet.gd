extends Resource

class_name StatSheet

# Core ability modifiers
var strength_mod: int
var dexterity_mod: int
var constitution_mod: int
var intelligence_mod: int
var wisdom_mod: int
var charisma_mod: int

# Saving throws
var fortitude: int
var reflex: int
var will: int

# Hit points
var max_hp: int

# Armor Class
var ac: int

# Other combat stats
var speed: int
var perception: int

# Resistances and weaknesses
var resistances: Dictionary
var weaknesses: Dictionary

# Initialize with default values
func _init():
	# Ability modifiers
	strength_mod = 0
	dexterity_mod = 0
	constitution_mod = 0
	intelligence_mod = 0
	wisdom_mod = 0
	charisma_mod = 0

	# Saving throws
	fortitude = 0
	reflex = 0
	will = 0

	# Hit points
	max_hp = 10

	# Armor Class
	ac = 10

	# Other combat stats
	speed = 30
	perception = 0

	# Resistances and weaknesses
	resistances = {}
	weaknesses = {}
