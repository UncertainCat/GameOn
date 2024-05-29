extends Resource

class_name StatSheet

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
