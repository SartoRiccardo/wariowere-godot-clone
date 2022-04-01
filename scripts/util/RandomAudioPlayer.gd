extends Node

export (int) var amount = 1

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func play():
	var children = get_children()
	for i in range(children.size()-1, -1, -1):
		if children[i].is_playing():
			children.remove(i)
	
	for __ in range(amount):
		if children.size() == 0:
			break
		var idx = rng.randi_range(0, children.size()-1)
		children.pop_at(idx).play()
		
