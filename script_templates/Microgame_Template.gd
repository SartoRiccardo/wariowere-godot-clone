extends "res://scripts/microgames/Microgame.gd"


func _ready():
	var bomb = $"/root/Helpers".get_bomb()
	if bomb:
		bomb.connect("explode", self, "on_microgame_timeout")

func _set_game_speed(new_speed):
	var components_to_update = []
	for cmp in components_to_update:
		cmp.set_game_speed(new_speed)

func set_difficulty(difficulty):
	pass

func start_minigame():
	$"/root/Helpers".ignite_bomb()
