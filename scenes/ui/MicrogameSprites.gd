extends Node

var game_speed = 1.0
var difficulty = GE.Difficulty.EASY

func get_anim_name(format, diff=null):
	if diff == null:
		diff = difficulty
	return format % $"/root/Helpers".get_difficulty_str(diff)

func set_game_speed(new_speed):
	game_speed = new_speed

func set_difficulty(new_difficulty):
	difficulty = new_difficulty

func ramp_up():
	pass

func level_up():
	pass

func boss_fight():
	pass

func speed_up():
	pass

func microgame_win():
	pass

func microgame_lose():
	pass

func set_to_idle_animation():
	pass
