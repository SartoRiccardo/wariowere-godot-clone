extends Node

signal timeout(win_on_timeout)
signal victory
signal loss

export (GE.Difficulty) var difficulty = GE.Difficulty.HARD
export (float) var time = 4.5
export (float) var game_speed = 1.0


func set_game_speed(new_speed):
	$"/root/Helpers".set_microgame_pitch(1/new_speed)
	_set_game_speed(new_speed)
	game_speed = new_speed	

# override
func _set_game_speed(_new_speed):
	pass
