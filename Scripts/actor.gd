extends Node2D

class_name Actor

var target_grid_position = Vector2i()
var speed = 200
var battle_map: BattleMap  # Reference to the Map node

@onready var sprite = $AnimatedSprite2D  # Reference to the AnimatedSprite

func assign(map: BattleMap):
	battle_map = map

func _ready():
	sprite.play("idle")  # Start with idle animation

func _process(delta):
	if battle_map:
		var target_position = battle_map.to_world(target_grid_position)
		if global_position != target_position:
			var direction = (target_position - global_position).normalized()
			global_position += direction * speed * delta
			if global_position.distance_to(target_position) < speed * delta:
				global_position = target_position
				sprite.play("idle")  # Play idle animation when the player reaches the target
				#var event = Event.new("move_completed", id)
				#event_bus.complete_event(event)
			else:
				sprite.play("walk_right")  # Play walk animation while the player is moving
		else:
			sprite.play("idle")  # Ensure the player is idle when not moving

func move_to_grid_position(new_grid_position: Vector2i):
	target_grid_position = new_grid_position
	print("Moving to new grid position: %s" % target_grid_position)

func handle_event(event: Event):
	if event.type == "move_player":
		print("Player received move_player event")
		move_to_grid_position(event.data.position)
