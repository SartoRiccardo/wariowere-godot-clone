extends "res://scripts/microgames/Microgame.gd"

onready var stop_point = $Events/StopPoint/CollisionShape2D
onready var jump_point = $Events/JumpPoint/CollisionShape2D
onready var turnback_point = $Events/TurnBackPoint/CollisionShape2D
onready var soundtrack = $MicrogameSoundtrack

var crazy_car
var won = true
onready var car_to_activate = $CrazyCar

func _ready():
	var car_type = $"/root/Helpers".rand_choice(
		[GE.CarType.ROCK, GE.CarType.SAUSAGE, GE.CarType.SHARK]
	)
	$CrazyCar.set_car_type(car_type)
	$SmallCrazyCar.set_car_type(car_type)
	
	$Player.connect("death", self, "on_player_death")
	var bomb = $"/root/Helpers".get_bomb()
	if bomb:
		bomb.connect("explode", self, "on_microgame_timeout")

func _set_game_speed(new_speed):
	var components_to_update = [$Player, soundtrack, $CrazyCar, $Camera]
	for cmp in components_to_update:
		cmp.set_game_speed(new_speed)

func set_difficulty(difficulty):
	var chances
	match difficulty:
		GE.Difficulty.EASY:
			chances = { GE.CarBehavior.NORMAL: 1.0 }
		GE.Difficulty.MEDIUM:
			chances = {
				GE.CarBehavior.NORMAL: 0.7,
				GE.CarBehavior.STOP: 0.3,
			}
		GE.Difficulty.HARD:
			chances = {
				GE.CarBehavior.NORMAL: 0.55,
				GE.CarBehavior.JUMP: 0.2,
				GE.CarBehavior.STOP: 0.2,
				GE.CarBehavior.TURNBACK: 0.1,
				GE.CarBehavior.SMALL: 0.05,
			}
	
	var behavior = $"/root/Helpers".rand_weighted_choice(chances)
	match behavior:
		GE.CarBehavior.STOP:
			stop_point.set_disabled(false)
		GE.CarBehavior.JUMP:
			jump_point.set_disabled(false)
		GE.CarBehavior.TURNBACK:
			turnback_point.set_disabled(false)
		GE.CarBehavior.SMALL:
			car_to_activate = $SmallCrazyCar

func start_minigame():
	$"/root/Helpers".ignite_bomb()
	soundtrack.play()
	car_to_activate.start()

func on_player_death():
	won = false
	emit_signal("loss")

func on_microgame_timeout():
	emit_signal("timeout", true)
