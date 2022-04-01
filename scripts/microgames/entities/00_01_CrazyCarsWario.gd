extends KinematicBody2D

enum State {ALIVE, DEAD}

signal death

onready var sound_jump = $Sounds/JumpSound
onready var sound_death = $Sounds/DeathSound

var state = State.ALIVE
var is_new_state = true
var velocity = Vector2(0, 1000)
var gravity = 1100
var jump_speed = 400 * -1
var game_speed = 1

func _ready():
	velocity = move_and_slide(velocity)  # Goes to ground no matter what
	$HurtBox.connect("area_entered", self, "on_hazard_entered")

func _process(delta):
	match state:
		State.ALIVE:
			process_alive(delta)
		State.DEAD:
			process_dead(delta)

func set_game_speed(new_speed):
	game_speed = new_speed
	sound_jump.set_game_speed(new_speed)
	sound_death.set_game_speed(new_speed)

func change_state(new_state):
	state = new_state
	is_new_state = true

func process_alive(delta):
	if $AnimatedSprite.animation == "jumping":
		$AnimatedSprite.play("jumped")
	if(Input.is_action_just_pressed("press_up")) and is_on_floor():
		$AnimatedSprite.play("jumping")
		sound_jump.play()
		velocity.y = jump_speed * game_speed

	velocity.y += gravity * delta * pow(game_speed, 2)
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if(is_on_floor()):
		$AnimatedSprite.play("idle")

func process_dead(_delta):
	if is_new_state:
		$AnimatedSprite.play("death")
		is_new_state = false

func die():
	change_state(State.DEAD)
	sound_death.play()
	emit_signal("death")

func on_hazard_entered(_area2d):
	die()
