extends Node

var game_speed = 1.0
var difficulty = GE.Difficulty.EASY

func set_game_speed(new_speed):
	game_speed = new_speed

func ramp_up():
	# Generic animation called when the game ramps up in general
	pass
	
func level_up():
	# Animation when the microgame level increases
	pass

func boss_fight():
	# Animation when a boss minigame is next
	pass

func speed_up():
	# Animation when the microgame speed increases
	pass

func microgame_win():
	# Animation when the microgame has been won
	pass

func microgame_lose():
	# Animation when the microgame has been lost
	pass

func set_to_idle_animation():
	# Resets the animations
	pass
