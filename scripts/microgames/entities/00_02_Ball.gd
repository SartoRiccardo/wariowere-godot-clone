extends KinematicBody2D

var movement_speed = 100
var game_speed = 1
var move_vector = Vector2.ZERO

func _ready():
	pass

func start():
	pass

func _process(delta):
	var movement = move_vector * game_speed * movement_speed * delta
	var collision = move_and_collide(movement)
	if collision:
		bounce()

func set_game_speed(new_speed):
	game_speed = new_speed

func set_sprite_rotation(rotation):
	$AnimatedSprite.set_rotation(rotation)

func bounce():
	var mov_x = move_vector.x
	var mov_y = move_vector.y
	if(move_and_collide(Vector2(-mov_x, mov_y), true, true, true)):
		set_angle(acos(mov_x) * -sign(mov_y))
	elif(move_and_collide(Vector2(mov_x, -mov_y), true, true, true)):
		set_angle(acos(-mov_x) * sign(mov_y))
	else:
		set_angle(acos(-mov_x) * -sign(mov_y))

func set_angle(angle):
	move_vector = Vector2(cos(angle), sin(angle))
	set_sprite_rotation(angle + deg2rad(90))
