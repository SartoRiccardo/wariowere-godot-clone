extends KinematicBody2D

onready var car_data = {
	GE.CarType.SAUSAGE: {"anim": "sausage", "hitbox": $Hitboxes/SausageHitbox},
	GE.CarType.SHARK: {"anim": "shark", "hitbox": $Hitboxes/SharkHitbox},
	GE.CarType.ROCK: {"anim": "rock", "hitbox": $Hitboxes/RockHitbox},
}
onready var sound_vroom = $VroomSound

var car_type = GE.CarType.SAUSAGE
var gravity = 900
var jump_speed = 400 *-1
var speed = 170 *-1
var game_speed = 1
var velocity = Vector2.ZERO
var stop_wait_time = 0.4
var played_audio = false

func _ready():
	set_car_type(car_type)
	$EventHitbox.connect("area_entered", self, "on_event_entered")

func start():
	velocity.x = speed * game_speed

func _process(delta):
	velocity.y += gravity * delta * pow(game_speed, 2)
	velocity = move_and_slide(velocity, Vector2.UP)

func set_game_speed(new_speed):
	velocity.x = velocity.x/game_speed * new_speed
	sound_vroom.set_game_speed(new_speed)
	game_speed = new_speed

func set_car_type(type):
	car_type = type
	set_car_animation()
	set_car_hitbox()

func set_car_animation():
	var anim_name = car_data[car_type]["anim"]
	$CarSprite.set_animation(anim_name)
	$"/root/Helpers".set_animatedsprite_offset($CarSprite, anim_name)
	$CarSprite.play()

func set_car_hitbox():
	var to_activate = car_data[car_type]["hitbox"]
	for hbx in $Hitboxes.get_children():
		hbx.set_disabled(hbx != to_activate)

func pause_car():
	velocity.x = 0
	$CarSprite._set_playing(false)
	pause_audio()

func keep_going():
	velocity.x = speed * game_speed
	$CarSprite._set_playing(true)
	resume_audio()

func turn_back():
	velocity.x = -speed * game_speed
	$CarSprite.set_flip_h(true)
	$CarSprite._set_playing(true)
	resume_audio()

func pause_audio():
	if sound_vroom.is_playing():
		sound_vroom.set_stream_paused(true)

func resume_audio():
	if sound_vroom.get_stream_paused():
		sound_vroom.set_stream_paused(false)

func on_event_entered(area2d):
	var layer = area2d.get_collision_layer()
	
	if $"/root/Helpers".is_collision_mask_on_layer(layer, GE.CarEventLayer.STOP):
		pause_car()
		var timer = get_tree().create_timer(stop_wait_time)
		timer.connect("timeout", self, "keep_going")
	elif $"/root/Helpers".is_collision_mask_on_layer(layer, GE.CarEventLayer.JUMP):
		velocity.y = jump_speed * game_speed
	elif $"/root/Helpers".is_collision_mask_on_layer(layer, GE.CarEventLayer.TURNBACK):
		pause_car()
		var timer = get_tree().create_timer(stop_wait_time)
		timer.connect("timeout", self, "turn_back")
	elif $"/root/Helpers".is_collision_mask_on_layer(layer, GE.CarEventLayer.SOUND):
		if not played_audio:
			sound_vroom.play()
		played_audio = true
