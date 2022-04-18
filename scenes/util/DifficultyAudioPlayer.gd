extends Node

signal finished

export (int) var difficulty

func set_difficulty(new_diff):
	difficulty = new_diff

func get_duration():
	for audio in get_children():
		if is_audio_elegible(audio):
			return audio.stream.get_length()
	return 0.0

func play():
	for audio in get_children():
		if is_audio_elegible(audio):
			audio.play()
			if not audio.is_connected("finished", self, "finish"):
				audio.connect("finished", self, "finish", [audio])

func is_audio_elegible(audio):
	var groups = audio.get_groups()
	return groups.find("easy") > -1 and difficulty == 0 or \
			groups.find("medium") > -1 and difficulty == 1 or \
			groups.find("hard") > -1 and difficulty == 2

func finish(audio):
	audio.disconnect("finished", self, "finish")
	emit_signal("finished")
