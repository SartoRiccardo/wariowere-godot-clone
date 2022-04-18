extends "res://scripts/microgames/Microgame.gd"

var amt_to_spawn = 1
var rng = RandomNumberGenerator.new()
var modulate = {
	GE.Difficulty.EASY: Color(1.0, 1.0, 1.0, 1.0),
	GE.Difficulty.MEDIUM: Color(0.0, 0.0, 1.0, 1.0),
	GE.Difficulty.HARD: Color(1.0, 0.0, 0.0, 1.0),
}

func _ready():
	var bomb = $"/root/Helpers".get_bomb()
	if bomb:
		bomb.connect("explode", self, "on_microgame_timeout")
	
	rng.randomize()

func _set_game_speed(new_speed):
	var components_to_update = [$Soundtrack, $Camera] + get_tree().get_nodes_in_group("player")
	print(components_to_update)
	for cmp in components_to_update:
		cmp.set_game_speed(new_speed)

func set_difficulty(difficulty):
	match difficulty:
		GE.Difficulty.EASY:
			amt_to_spawn = 1
		GE.Difficulty.MEDIUM:
			amt_to_spawn = 2
		GE.Difficulty.HARD:
			amt_to_spawn = 3
	$TileMap.set_modulate(modulate[difficulty])

func start_minigame():
	var random_point = Vector2(
		rng.randf_range($NWCorner.get_position().x, $SECorner.get_position().x),
		rng.randf_range($NWCorner.get_position().y, $SECorner.get_position().y)
	)
	
	var spawner_distances = []
	for spawner in $CoinSpawners.get_children():
		var distance = random_point.distance_to(spawner.get_position())
		spawner_distances.append({ "spawner": spawner, "distance": distance })
		
	spawner_distances.sort_custom(self, "sort_spawner_distances_asc")
	for i in range(amt_to_spawn):
		spawner_distances[i]["spawner"].start()
	
	$Soundtrack.play()
	$"/root/Helpers".ignite_bomb()

func on_microgame_timeout():
	emit_signal("timeout", $Coins.get_children().size() == 0)

func sort_spawner_distances_asc(a, b):
	return a["distance"] < b["distance"]
