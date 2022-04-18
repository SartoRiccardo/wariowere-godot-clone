extends "res://scenes/ui/MicrogameSprites.gd"

func set_game_speed(new_speed):
	$WarioScreen.set_speed_scale(new_speed)
	game_speed = new_speed

func ramp_up():
	var coro = $"/root/Helpers".fade_animatedsprite($WarioScreen, get_anim_name("%s_idle"))
	yield(coro, "completed")

func level_up():
	$WarioScreen.play("info_level_up")

func boss_fight():
	$WarioScreen.play("info_boss")

func speed_up():
	$WarioScreen.play("info_speed")

func microgame_win():
	$WarioScreen.play(get_anim_name("%s_success"))
	yield($WarioScreen, "animation_finished")
	set_to_idle_animation()

func microgame_lose():
	$WarioScreen.play(get_anim_name("%s_fail"))
	yield($WarioScreen, "animation_finished")
	set_to_idle_animation()

func set_to_idle_animation():
	$WarioScreen.play(get_anim_name("%s_idle"))
