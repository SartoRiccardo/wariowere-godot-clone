extends Node

export (Array, PackedScene) var microgames
export (int) var lives = 4
export (GE.Difficulty) var difficulty = GE.Difficulty.EASY
export (int) var ramp_up_interval = 3

onready var microgame_gui = $CanvasLayer/LevelGUIContainer/Viewport/LevelGUI
enum MicrogameState { LOST, WON, UNKNOWN }

var rng = RandomNumberGenerator.new()
var game_speed = 1.0
var game_speed_incr = 0.1
var level_pool = []
var current_microgame = null
var microgame_state = MicrogameState.UNKNOWN
var microgame_counter = 0
var ramp_up_count = 0
var speed_increase_count = 0

func _ready():
	rng.randomize()
	reset_microgame_pool()
	microgame_gui.connect("zoomed_out", self, "remove_microgame")
	call_deferred("spawn_microgame")

func _process(_delta):
	pass

func spawn_microgame():
	var start_sound_duration = $Sounds/MicrogameStart.get_duration() - 0.3
	$Sounds/MicrogameStart.play()
	var start_delay = get_tree().create_timer(start_sound_duration / game_speed)
	yield(start_delay, "timeout")
	
	microgame_state = MicrogameState.UNKNOWN
	var microgame_idx = $"/root/Helpers".rand_choice(level_pool)
	current_microgame = microgames[microgame_idx].instance()
	current_microgame.connect("timeout", self, "_on_microgame_timeout")
	current_microgame.connect("loss", self, "_on_microgame_loss")
	current_microgame.connect("victory", self, "_on_microgame_win")
#	$MicrogameViewport/Viewport.add_child(current_microgame)
	$MicrogameContainer.add_child(current_microgame)
	current_microgame.set_game_speed(game_speed)
	current_microgame.set_difficulty(difficulty)
	microgame_gui.enter_microgame()
	current_microgame.start_minigame()

func remove_microgame():
	if current_microgame:
		current_microgame.queue_free()

func gain_life():
	lives = max(lives+1, 4)

func lose_life():
	lives = max(lives-1, 0)

func increase_speed(incr=game_speed_incr):
	set_game_speed(game_speed+incr)
	speed_increase_count += 1

func set_game_speed(amt):
	$Sounds/RampUp.set_game_speed(amt)
	for audio_controller in get_tree().get_nodes_in_group("audio_speed_controller"):
		audio_controller.set_game_speed(amt)
	game_speed = amt
	microgame_gui.set_game_speed(amt)

func increase_difficulty(loop_back=false):
	var has_increased = true
	match difficulty:
		GE.Difficulty.EASY:
			difficulty = GE.Difficulty.MEDIUM
		GE.Difficulty.MEDIUM:
			difficulty = GE.Difficulty.HARD
		GE.Difficulty.HARD:
			difficulty = GE.Difficulty.EASY if loop_back else GE.Difficulty.HARD
			has_increased = loop_back
	
	return has_increased

func reset_microgame_pool():
	for i in range(microgames.size()):
		level_pool.append(i)

func win_microgame(immediate=false):
	if microgame_state == MicrogameState.WON:
		return
		
	microgame_state = MicrogameState.WON
	if not immediate:
		var timer = get_tree().create_timer(0.7)
		yield(timer, "timeout")
	$Sounds/WinAudioPlayer.play()

func lose_microgame(immediate=false):
	if microgame_state == MicrogameState.LOST:
		return
		
	microgame_state = MicrogameState.LOST
	if not immediate:
		var timer = get_tree().create_timer(0.7)
		yield(timer, "timeout")
	$Sounds/DeathAudioPlayer.play()

func set_microgame_counter(amt):
	microgame_counter = amt
	microgame_gui.set_microgame_counter(microgame_counter)

func _on_microgame_win():
	win_microgame()

func _on_microgame_loss():
	lose_microgame()

func _on_microgame_timeout(win_on_timeout):
	microgame_gui.exit_microgame()
	set_microgame_counter(microgame_counter + 1)
	
	var delay = get_tree().create_timer(0.3)
	yield(delay, "timeout")
	
	if microgame_state == MicrogameState.UNKNOWN and not win_on_timeout or \
			microgame_state == MicrogameState.LOST:
		var immediate_loss = microgame_state == MicrogameState.LOST
		lose_microgame(immediate_loss)
		microgame_gui.lose_life()
		microgame_gui.microgame_lose()
		$Sounds/MicrogameLoss.play()
		yield(microgame_gui, "animation_finished")
	else:
		win_microgame(true)
		$Sounds/MicrogameVictory.play()
		microgame_gui.microgame_win()
		yield(microgame_gui, "animation_finished")
	
	if microgame_counter % ramp_up_interval == 0:
		var has_levelled_up = ramp_up()
		microgame_gui.ramp_up(has_levelled_up)
		$Sounds/RampUp.play()
		var ramp_up_delay = $Sounds/RampUp.stream.get_length() - 0.2
		var ramp_up_timer = get_tree().create_timer(ramp_up_delay / game_speed)
		yield(ramp_up_timer, "timeout")
		microgame_gui.set_to_idle_animation()
	
	get_tree().create_timer(0.4 / game_speed).connect("timeout", self, "spawn_microgame")

# Override
func ramp_up():
	var has_increased
	ramp_up_count += 1
	var speed_increase = game_speed_incr * pow(0.9, speed_increase_count)
	if ramp_up_count % 3 == 0:
		has_increased = increase_difficulty()
		if not has_increased:
			increase_speed(speed_increase)
		else:
			set_game_speed(1.0)
	else:
		increase_speed(speed_increase)
		has_increased = false
	
	for audio_player in get_tree().get_nodes_in_group("difficulty_audio_player"):
		audio_player.set_difficulty(ramp_up_count % 3)
		
	return has_increased
