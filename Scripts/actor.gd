extends Node2D

class_name Actor

var target_grid_position = Vector2i()
var sprite_speed = 200
var battle_map: BattleMap  # Reference to the Map node
var stat_sheet: StatSheet  # The actor's stat sheet
var is_moving = false  # Flag to check if the actor is currently moving
var action_cards = Array[ActionCard]

@onready var sprite = $AnimatedSprite2D  # Reference to the AnimatedSprite

# Store the current event
var complete_movement: Callable

func _init():
	stat_sheet = StatSheet.new()

func assign(map: BattleMap):
	battle_map = map

func _ready():
	sprite.play("idle")  # Start with idle animation
	game_event_queue.register_listener(MoveActorGameEvent.get_register(), _on_move_event)

func _process(delta):
	if is_moving and battle_map:
		var target_position = battle_map.to_world(target_grid_position)
		if global_position != target_position:
			var direction = (target_position - global_position).normalized()
			global_position += direction * sprite_speed * delta
			if global_position.distance_to(target_position) < sprite_speed * delta:
				global_position = target_position
				sprite.play("idle")  # Play idle animation when the player reaches the target
				is_moving = false
			else:
				sprite.play("walk_right")  # Play walk animation while the player is moving
		else:
			sprite.play("idle")  # Ensure the player is idle when not moving
			is_moving = false
	if is_moving == false and complete_movement:
		complete_movement.call()

# Move to a new grid position
func move_to_grid_position(new_grid_position: Vector2i):
	target_grid_position = new_grid_position
	is_moving = true
	print("Moving to new grid position: %s" % target_grid_position)

# Handle the move event
func _on_move_event(on_complete: Callable, event: MoveActorGameEvent) -> void:
	print("Player received move_player event")
	complete_movement = on_complete
	move_to_grid_position(event.to)

func can_walk() -> bool:
	return true

func evaluate_walk_speed() -> int:
	return 6
