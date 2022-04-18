extends KinematicBody2D

enum Event { BOUNDARY=13, DESPAWN=14 }

var grid_snap_x = 80
var grid_snap_y = 48

var game_speed = 1.0
var movements = []
var mov_speed = 150
var prev_mov_vector = Vector2.ZERO
var can_switch_directions = true
var spawned_on_boundary = false

func _ready():
	$EdgeCollider.connect("area_entered", self, "_on_edge_collider_enter")
	$EdgeCollider.connect("area_exited", self, "_on_edge_collider_exited")

func start():
	pass

func _process(delta):
	handle_inputs()
	var mov_vector = get_movement_vector()
	
	var frame_velocity = mov_vector * mov_speed * game_speed
	var velocity = move_and_slide(frame_velocity)
	mov_vector = Vector2(sign(velocity.x), sign(velocity.y))
	set_correct_animation(mov_vector)
	snap_to_grid(mov_vector)
	
	prev_mov_vector = mov_vector

func handle_inputs():
	var inputs = {
		"press_down": Vector2.DOWN,
		"press_up": Vector2.UP,
		"press_left": Vector2.LEFT,
		"press_right": Vector2.RIGHT
	}
	
	for input in inputs.keys():
		var action = inputs[input]
		if Input.is_action_just_released(input) or Input.is_action_just_pressed(input):
			var idx = movements.find(action)
			if idx >= 0:
				movements.remove(idx)
				
			if Input.is_action_just_pressed(input):
				movements.append(action)

func get_movement_vector():
	var vec = prev_mov_vector
	for i in range(movements.size()):
		var idx = movements.size()-1 - i
		var mvmt = movements[idx]
		if mvmt.x != 0:
			vec.x = mvmt.x
		if mvmt.y != 0:
			vec.y = mvmt.y
	return vec

func set_correct_animation(mov_vector):
	if mov_vector == Vector2.ZERO:
		$AnimatedSprite.stop()
		$AnimatedSprite.set_frame(0)
	else:
		$AnimatedSprite.play()
	
	match mov_vector:
		Vector2.RIGHT, Vector2.LEFT:
			$AnimatedSprite.set_animation("walk_right")
			$AnimatedSprite.set_flip_h(mov_vector == Vector2.LEFT)
		Vector2.UP:
			$AnimatedSprite.set_animation("walk_up")
			$AnimatedSprite.set_flip_h(false)
		Vector2.DOWN:
			$AnimatedSprite.set_animation("walk_down")
			$AnimatedSprite.set_flip_h(false)

func snap_to_grid(mov_vector):
	var position = get_global_position()
	match mov_vector:
		Vector2.RIGHT, Vector2.LEFT:
			position.y = grid_snap_y * round(position.y/grid_snap_y)
		Vector2.DOWN, Vector2.UP:
			position.x = grid_snap_x * round(position.x/grid_snap_x)
		Vector2.ZERO:
			position = $AnimatedSprite.get_global_position()
	
	$AnimatedSprite.set_global_position(position)

func set_game_speed(new_speed):
	game_speed = new_speed

func duplicate_wario():
	var instance = duplicate()
	instance.grid_snap_x = grid_snap_x
	instance.grid_snap_y = grid_snap_y
	instance.game_speed = game_speed
	instance.movements = movements
	instance.mov_speed = mov_speed
	instance.prev_mov_vector = prev_mov_vector
	instance.can_switch_directions = can_switch_directions
	instance.spawned_on_boundary = spawned_on_boundary
	return instance

func _on_edge_collider_enter(area2d):
	if spawned_on_boundary:
		return
	
	var mask = area2d.get_collision_mask()
	if $"/root/Helpers".is_collision_mask_on_layer(mask, Event.DESPAWN):
		queue_free()
	elif $"/root/Helpers".is_collision_mask_on_layer(mask, Event.BOUNDARY):
		var closest_shape = null
		var distance = 0
		var next_shape = null
		
		var collision_shapes = area2d.get_children()
		for i in range(collision_shapes.size()):
			var collision_shape = collision_shapes[i]
			if closest_shape == null or \
					collision_shape.global_position.distance_to(global_position) < distance:
				closest_shape = collision_shape
				distance = closest_shape.global_position.distance_to(global_position)
				var next_idx = (i+1) % collision_shapes.size()
				next_shape = collision_shapes[next_idx]
		
		var duplicate_position = next_shape.global_position + (global_position - closest_shape.global_position)
		var new_wario = duplicate_wario()
		new_wario.global_position = duplicate_position
		new_wario.spawned_on_boundary = true
		get_parent().add_child_below_node(self, new_wario)

func _on_edge_collider_exited(_a2d):
	spawned_on_boundary = false
