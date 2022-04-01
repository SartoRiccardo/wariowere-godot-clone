extends Node

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func set_animatedsprite_offset(animated_sprite, anim_name):
	var size = get_animatedsprite_size(animated_sprite, anim_name)
	animated_sprite.set_offset(Vector2(0, size.y) / -2)

func get_animatedsprite_size(animated_sprite, anim_name):
	return animated_sprite.frames.get_frame(anim_name, 0).get_size()

func rand_choice(array):
	var idx = rng.randi() % array.size()
	return array[idx]

func rand_weighted_choice(dict):
	var chance = rng.randf()
	var choice = null
	for key in dict.keys():
		if chance <= dict[key]:
			return key
		chance -= dict[key]
	return choice

func is_collision_mask_on_layer(mask, layer):
	return int(mask/pow(2, layer-1)) % 2 == 1

func get_first_of_group(group_name):
	var members = get_tree().get_nodes_in_group(group_name)
	if members.size():
		return members[0]
	return null

func current_microgame():
	return get_first_of_group("microgame")

func get_bomb():
	return get_first_of_group("bomb")

func ignite_bomb():
	var bomb = get_first_of_group("bomb")
	if bomb:
		bomb.start_bomb()

func set_microgame_pitch(value):
	var sfx_bus = AudioServer.get_bus_index("Microgame-SFX")
	var ost_bus = AudioServer.get_bus_index("Microgame-Soundtrack")
	for bus in [sfx_bus, ost_bus]:
		var pitch_eff = AudioServer.get_bus_effect(bus, 0)
		pitch_eff.set_pitch_scale(value)
