extends "res://scripts/microgames/Microgame.gd"

var wario_up_speed = -200
var wario_gravity = 800
var rotation_speed_active = -deg2rad(200)

var rotation_speed = 0
var stopped = false
var pressed = false
var wario_velocity_y = 0
var wario_accel = 0

func _ready():
	var bomb = $"/root/Helpers".get_bomb()
	if bomb:
		bomb.connect("explode", self, "on_microgame_timeout")
	$WhirlStopper.connect("succeeded", self, "_on_wario_stopped")
	$WhirlStopper.connect("failed", self, "_on_wario_fail")

func _process(delta):
	if Input.is_action_just_pressed("press_a") and not pressed:
		pressed = true
		$WhirlStopper.move()
	
	$WarioContainer/Wario.global_position.y += wario_velocity_y * delta*game_speed
	wario_velocity_y += wario_accel * delta*game_speed
	
	if stopped:
		rotation_speed = lerp(0, rotation_speed, pow(2, -15*delta))
	
	var current_rotation = $WarioContainer.get_rotation()
	$WarioContainer.set_rotation(current_rotation + rotation_speed*delta*game_speed)

func _set_game_speed(new_speed):
	var components_to_update = [$BGM, $Camera]
	for cmp in components_to_update:
		cmp.set_game_speed(new_speed)

func set_difficulty(difficulty):
	$WarioContainer/WhirledArc.set_difficulty(difficulty)

func start_minigame():
	$"/root/Helpers".ignite_bomb()
	$BGM.play()
	rotation_speed = rotation_speed_active

func _on_wario_stopped():
	stopped = true
	emit_signal("victory")

func _on_wario_fail():
	rotation_speed = 0
	wario_velocity_y = wario_up_speed
	wario_accel = wario_gravity
	$WarioFail.play()
	emit_signal("loss")

func on_microgame_timeout():
	emit_signal("timeout", false)
