extends KinematicBody2D

var game_speed = 1
var gravity = 900
var speed = 170 *-1
var velocity = Vector2.ZERO
var sound_played = false

func _ready():
	$HurtBox.connect("area_entered", self, "on_death")
	$SoundTriggerer.connect("area_entered", self, "on_sound_triggered")

func start():
	velocity.x = speed * game_speed

func _process(delta):
	velocity.y += gravity * delta * pow(game_speed, 2)
	velocity = move_and_slide(velocity)

func set_car_type(type):
	var anim_name = "rock"
	match type:
		GE.CarType.SAUSAGE:
			anim_name = "sausage"
		GE.CarType.SHARK:
			anim_name = "shark"
	
	$AnimatedSprite.set_animation(anim_name)
	$"/root/Helpers".set_animatedsprite_offset($AnimatedSprite, anim_name)

func set_game_speed(new_speed):
	$AudioSpeedController.set_game_speed(new_speed)
	game_speed = new_speed

func on_death(_a2d):
	velocity = Vector2(-sign(velocity.x) * 100, -200)
	set_collision_mask_bit(0, false)
	$AnimatedSprite.stop()
	$AnimatedSprite.set_flip_v(true)

func on_sound_triggered(_a2d):
	if not sound_played:
		$AudioSpeedController.play()
	sound_played = true
