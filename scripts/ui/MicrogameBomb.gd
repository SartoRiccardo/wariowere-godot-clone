extends MarginContainer

signal explode

onready var bomb = $VBoxContainer/Bomb
onready var bomb_fuse = $VBoxContainer/Bomb/Fuse
onready var bomb_spark = $VBoxContainer/Bomb/SparkContainer/Spark
onready var bomb_counter = $VBoxContainer/Counter

var tick_duration = 1/3.0
var idle_time = 3.0
var microgame_bomb_counters = [
	preload("res://resources/textures/MicrogameBomb1.tres"),
	preload("res://resources/textures/MicrogameBomb2.tres"),
	preload("res://resources/textures/MicrogameBomb3.tres"),
]

var game_speed = 1
var seconds_until_show = 0
var seconds_until_start = 0

func _ready():
	var minigame = $"/root/Helpers".current_microgame()
	if minigame:
		var time = minigame.time
		var fuse_amount = get_available_fuses().size()
		var active_bomb_time = fuse_amount * tick_duration
		
		seconds_until_start = time - active_bomb_time
		seconds_until_start = clamp(seconds_until_start, 0, idle_time)
		seconds_until_show = time - active_bomb_time - idle_time
		seconds_until_show = clamp(seconds_until_show, 0, 100)
		if seconds_until_show == 0:
			bomb.show()
#		print("ACTIVE\t\tIDLE\t\tHIDDEN\n%s\t%s\t%s" % [active_bomb_time, seconds_until_start, seconds_until_show])

# "BombBegin" is also a fuse, not contained in the "Fuse" container node.
# This means that the total fuses are always Fuse.children + 1
func bomb_tick():
	var available_fuses = get_available_fuses()
	
	if available_fuses.size() > 0:
		var idx = available_fuses.size()-1
		available_fuses[idx].hide()
		available_fuses.remove(idx)
	
	if available_fuses.size() < 3:
		show_bomb_counter(available_fuses.size()+1)

	if available_fuses.size() == 0:
		var spark_position = bomb_spark.get_position()
		spark_position.y = -12
		bomb_spark._set_position(spark_position)
	
	return available_fuses.size()

func get_available_fuses():
	var available_fuses = bomb_fuse.get_children()
	for i in range(available_fuses.size()-1, -1, -1):
		var fuse = available_fuses[i]
		if not fuse.is_visible():
			available_fuses.remove(i)
	return available_fuses

func show_bomb_counter(number):
	bomb_counter.set_texture(microgame_bomb_counters[number-1])
	bomb_counter.show()

func set_game_speed(speed):
	game_speed = speed

func explode():
	emit_signal("explode")

func start_bomb():
	if seconds_until_show > 0:
		var timer = get_tree().create_timer(seconds_until_show / game_speed)
		yield(timer, "timeout")
		seconds_until_show = 0
	bomb.show()

	if seconds_until_start > 0:
		var timer = get_tree().create_timer(seconds_until_start / game_speed)
		yield(timer, "timeout")
		seconds_until_start = 0
	bomb_spark.show()
	
	var remaining_ticks = bomb_tick()
	var timer = get_tree().create_timer(tick_duration / game_speed)
	if remaining_ticks <= 0:
		timer.connect("timeout", self, "explode")
	else:
		timer.connect("timeout", self, "start_bomb")
