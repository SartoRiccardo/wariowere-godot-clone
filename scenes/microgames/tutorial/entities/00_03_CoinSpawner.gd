extends Position2D

enum Direction { HORIZONTAL, VERTICAL }
export (Direction) var spawn_direction = Direction.HORIZONTAL
export (NodePath) var spawn_parent = null

var coin_distance = 16
var game_speed = 1.0
var coin_scene = preload("res://scenes/microgames/tutorial/entities/00_03_Coin.tscn")

func start():
	var amt_spawned = 4 if spawn_direction == Direction.HORIZONTAL else 2
	var distance = coin_distance * (amt_spawned-1) / -2
	for _i in amt_spawned:
		var coin_position = Vector2.RIGHT if spawn_direction == Direction.HORIZONTAL else Vector2.UP
		coin_position *= distance
		coin_position += global_position
		distance += coin_distance
		
		var coin = coin_scene.instance()
		coin.set_position(coin_position)
		if spawn_parent == null:
			add_child(coin)
		else:
			get_node(spawn_parent).add_child(coin)

func set_game_speed(new_speed):
	game_speed = new_speed
