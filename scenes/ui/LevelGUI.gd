extends Node

signal animation_finished
signal zoomed_out

var game_speed = 1
var difficulty = GE.Difficulty.EASY

func set_game_speed(new_speed):
	for life in $Lives.get_children():
		life.set_game_speed(new_speed)
	$MicrogameSprites.set_game_speed(new_speed)

func lose_life():
	var last_alive = null
	for life in $Lives.get_children():
		if not life.is_active():
			break
		last_alive = life
	
	if last_alive:
		last_alive.die()

func gain_life():
	pass

func get_difficulty_str(diff=null):
	if diff == null:
		diff = difficulty
	match diff:
		GE.Difficulty.EASY:
			return "easy"
		GE.Difficulty.MEDIUM:
			return "medium"
		GE.Difficulty.HARD:
			return "hard"

func set_difficulty(new_difficulty):
	difficulty = new_difficulty
	$MicrogameSprites.set_difficulty(new_difficulty)

func ramp_up(level_up=false, boss_fight=false):
	var new_difficulty
	match difficulty:
		GE.Difficulty.EASY:
			new_difficulty = GE.Difficulty.MEDIUM
		GE.Difficulty.MEDIUM:
			new_difficulty = GE.Difficulty.HARD
		GE.Difficulty.HARD:
			new_difficulty = GE.Difficulty.EASY
	
	set_difficulty(new_difficulty)
	var coro = $MicrogameSprites.ramp_up()
	yield(coro, "completed")
	
	if level_up:
		$MicrogameSprites.level_up()
	elif boss_fight:
		$MicrogameSprites.boss_fight()
	else:
		$MicrogameSprites.speed_up()

func set_microgame_counter(amt):
	$MicrogameCounter.set_text("%03d" % amt)

func microgame_win():
	var coro = $MicrogameSprites.microgame_win()
	yield(coro, "completed")
	set_to_idle_animation()

func microgame_lose():
	var coro = $MicrogameSprites.microgame_lose()
	yield(coro, "completed")
	set_to_idle_animation()

func set_to_idle_animation():
	$MicrogameSprites.set_to_idle_animation()
	emit_signal("animation_finished")

func enter_microgame():
	$AnimationPlayer.play("enter_microgame")

func exit_microgame():
	$AnimationPlayer.play_backwards("enter_microgame")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("zoomed_out")
