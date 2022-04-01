extends "res://scripts/microgames/Microgame.gd"

var rng = RandomNumberGenerator.new()

var ball_distance = 32
var ball_scene = preload("res://scenes/microgames/tutorial/entities/00_02_ball.tscn")
var ball_num = 2

var ball_rotate_speed = 100
var ball_rotate_time = 1
var ball_rotate_time_rand = 0.3
var are_balls_rotating = true
var game_started = false

func _ready():
	var bomb = $"/root/Helpers".get_bomb()
	if bomb:
		bomb.connect("explode", self, "on_microgame_timeout")
	
	rng.randomize()
	.set_game_speed(game_speed)
	set_difficulty(difficulty)
	call_deferred("start_minigame")

func _process(delta):
	if not game_started:
		return
	
	if are_balls_rotating:
		var new_rotation = $Balls.get_rotation() + deg2rad(ball_rotate_speed)*delta*game_speed
		$Balls.set_rotation(new_rotation)

func _set_game_speed(new_speed):
	var components_to_update = [$Car, $Camera, $Soundtrack] + $Balls.get_children()
	for cmp in components_to_update:
		cmp.set_game_speed(new_speed)

func set_difficulty(difficulty):
	match difficulty:
		GE.Difficulty.EASY:
			ball_num = 2
		GE.Difficulty.MEDIUM:
			ball_num = 3
		GE.Difficulty.HARD:
			ball_num = 4

func start_minigame():
	create_balls()
	$"/root/Helpers".ignite_bomb()
	$Soundtrack.play()

func create_balls():
	for i in range(ball_num):
		var ball = ball_scene.instance()
		var angle = deg2rad(i * 360/ball_num)
		ball.set_position(Vector2(
			stepify(sin(angle)*ball_distance, 0.001),
			stepify(cos(angle)*ball_distance, 0.001)
		))
		ball.set_sprite_rotation(-angle)
		ball.set_game_speed(game_speed)
		$Balls.add_child(ball)
	game_started = true
	start_rotation_end_timer()

func start_rotation_end_timer():
	var variation = ball_rotate_time*ball_rotate_time_rand
	var wait_time = rng.randf_range(ball_rotate_time-variation, ball_rotate_time+variation)
	var timer = get_tree().create_timer(wait_time / game_speed)
	yield(timer, "timeout")
	are_balls_rotating = false
	call_deferred("init_balls_movement_vector")

func init_balls_movement_vector():
	var initial_angle = $Balls.get_rotation()
	for ball in $Balls.get_children():
		var pos = ball.get_position()
		var angle_from_center
		if pos.x == 0:
			angle_from_center = deg2rad(90) * sign(pos.y)
		elif pos.y == 0:
			angle_from_center = deg2rad(180) if sign(pos.x) == -1 else 0
		else:
			angle_from_center = atan(pos.y/pos.x)
			if sign(pos.x) == -1:
				angle_from_center += deg2rad(180)
		angle_from_center += initial_angle
		
#		print("POS: %s, ANGLE: %s" % [pos, stepify(rad2deg(angle_from_center), 0.001)])
		ball.set_angle(angle_from_center)

func on_microgame_timeout():
	emit_signal("timeout", true)
