extends Control

# List of current actors in the initiative order
var current_order = []
var target_positions = []
var animation_queue = []
var animation_duration = 0.5
var animation_elapsed = 0

# Nodes
@onready var actor_container = $ActorContainer

func setup():
	# Initial setup if needed
	pass

func update_order(new_order):
	# Save the new order
	current_order = new_order
	# Calculate target positions for the new order
	_calculate_target_positions()
	# Add reordering to the animation queue
	enqueue_animation("reorder")
	_process_next_animation()

func add_actor(actor):
	# Add actor to the current order
	current_order.append(actor)
	# Add actor addition to the animation queue
	enqueue_animation("add", actor)
	_process_next_animation()

func remove_actor(actor):
	# Remove actor from the current order
	current_order.erase(actor)
	# Add actor removal to the animation queue
	enqueue_animation("remove", actor)
	_process_next_animation()

func _calculate_target_positions():
	# Calculate target positions based on the current order
	target_positions.clear()
	for i in range(len(current_order)):
		target_positions.append(Vector2(i * 150, 0)) # Adjust 150 based on panel width + spacing

func enqueue_animation(type, actor = null):
	# Add an animation task to the queue
	animation_queue.append({"type": type, "actor": actor})

func _process_next_animation():
	# Process the next animation in the queue
	if animation_queue.size() > 0 and not is_processing():
		animation_elapsed = 0
		set_process(true)
		var animation_task = animation_queue.pop_front()
		match animation_task.type:
			"reorder":
				_animate_reorder()
			"add":
				_animate_add(animation_task.actor)
			"remove":
				_animate_remove(animation_task.actor)

func _animate_reorder():
	# Start reordering animation
	animation_elapsed = 0
	set_process(true)

func _animate_add(actor):
	# Start adding actor animation
	var actor_panel = preload("res://Scenes/Gui/ActorPanel.tscn").instantiate()
	actor_panel.update_actor(actor)
	actor_panel.rect_position = Vector2(actor_container.rect_size.x / 2, -actor_panel.rect_size.y)
	actor_container.add_child(actor_panel)
	animation_elapsed = 0
	set_process(true)

func _animate_remove(actor):
	# Start removing actor animation
	for child in actor_container.get_children():
		if child.get_actor() == actor:
			animation_elapsed = 0
			set_process(true)
			break

func _process(delta):
	if animation_elapsed < animation_duration:
		animation_elapsed += delta
		var t = animation_elapsed / animation_duration
		if animation_queue.size() > 0:
			var animation_task = animation_queue.front()
			match animation_task.type:
				"reorder":
					_update_positions_reorder(t)
				"add":
					_update_positions_add(animation_task.actor, t)
				"remove":
					_update_positions_remove(animation_task.actor, t)
	else:
		set_process(false)
		_finalize_animation()

func _update_positions_reorder(t):
	# Update positions for reordering animation
	for i in range(actor_container.get_child_count()):
		var child = actor_container.get_child(i)
		var start_pos = child.rect_position
		var end_pos = target_positions[i]
		child.rect_position = start_pos.lerp(end_pos, t)

func _update_positions_add(actor, t):
	# Update positions for adding actor animation
	for i in range(actor_container.get_child_count()):
		var child = actor_container.get_child(i)
		if child.get_actor() == actor:
			var start_pos = child.rect_position
			var end_pos = Vector2(i * 150, 0)
			child.rect_position = start_pos.lerp(end_pos, t)

func _update_positions_remove(actor, t):
	# Update positions for removing actor animation
	for child in actor_container.get_children():
		if child.get_actor() == actor:
			var start_pos = child.rect_position
			var end_pos = Vector2(child.rect_position.x, -child.rect_size.y)
			child.rect_position = start_pos.lerp(end_pos, t)

func _finalize_animation():
	# Finalize the current animation
	if animation_queue.size() > 0:
		var animation_task = animation_queue.front()
		match animation_task.type:
			"reorder":
				_finalize_positions_reorder()
			"add":
				_finalize_positions_add(animation_task.actor)
			"remove":
				_finalize_positions_remove(animation_task.actor)
		_process_next_animation()

func _finalize_positions_reorder():
	# Ensure final positions for reordering animation
	for i in range(actor_container.get_child_count()):
		var child = actor_container.get_child(i)
		child.rect_position = target_positions[i]

func _finalize_positions_add(actor):
	# Ensure final positions for adding actor animation
	for i in range(actor_container.get_child_count()):
		var child = actor_container.get_child(i)
		if child.get_actor() == actor:
			child.rect_position = Vector2(i * 150, 0)

func _finalize_positions_remove(actor):
	# Ensure final positions for removing actor animation and free node
	for child in actor_container.get_children():
		if child.get_actor() == actor:
			child.queue_free()

func _update_panels():
	# Clear existing panels
	actor_container.queue_free_children()

	# Create new actor panels
	for i in range(len(current_order)):
		var actor = current_order[i]
		var actor_panel = preload("res://Scenes/Gui/ActorPanel.tscn").instantiate()
		actor_panel.update_actor(actor)
		actor_panel.rect_position = Vector2(i * 150, 0) # Adjust based on panel width + spacing
		actor_container.add_child(actor_panel)
