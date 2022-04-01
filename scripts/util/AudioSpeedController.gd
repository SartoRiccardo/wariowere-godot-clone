extends AudioStreamPlayer

var game_speed = 1

func _ready():
	set_pitch_scale(game_speed)

func set_game_speed(speed):
	game_speed = speed
	set_pitch_scale(game_speed)
