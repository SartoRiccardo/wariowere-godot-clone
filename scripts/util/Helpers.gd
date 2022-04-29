extends Node

var rng = RandomNumberGenerator.new()
var fade_out_animation = preload("res://resources/fade_out_anim.tres")

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

func get_difficulty_str(difficulty):
	match difficulty:
		GE.Difficulty.EASY:
			return "easy"
		GE.Difficulty.MEDIUM:
			return "medium"
		GE.Difficulty.HARD:
			return "hard"

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
	return  # Function isn't really needed, it's only if pitch needs to remain the same
#	var sfx_bus = AudioServer.get_bus_index("Microgame-SFX")
#	var ost_bus = AudioServer.get_bus_index("Microgame-Soundtrack")
#	for bus in [sfx_bus, ost_bus]:
#		var pitch_eff = AudioServer.get_bus_effect(bus, 0)
#		pitch_eff.set_pitch_scale(value)

func fade_animatedsprite(sprite: AnimatedSprite, anim_name, _duration=1.0):
	# Duplicate result below
	var fade_to = sprite.duplicate()
	var parent_node = sprite.get_parent()
	parent_node.add_child(fade_to)
	parent_node.move_child(fade_to, sprite.get_index())
	fade_to.play(anim_name)
	
	# Add AnimationPlayer to fade
	var anim_player = AnimationPlayer.new()
	anim_player.add_animation("fade_out", fade_out_animation)
	anim_player.play("fade_out")
	sprite.add_child(anim_player)
	yield(anim_player, "animation_finished")
	
	# Cleanup
	sprite.set_modulate(Color(1, 1, 1, 1))
	sprite.play(anim_name)
	fade_to.queue_free()

func play_sound_globally(player: AudioStreamPlayer):
	var audio_to_play = player.duplicate()
	add_child(audio_to_play)
	audio_to_play.play()
	yield(audio_to_play, "finished")
	remove_child(audio_to_play)
