extends KinematicBody2D

signal player_death

onready var death_particles = $DeathParticles/Particles2D

var particle_amt = 12
var game_speed = 1
var move_speed = 120
var inputs = []
var velocity = Vector2.ZERO
var prev_move_vector = Vector2.ZERO
var alive = true
var stopped = false

func _ready():
	$HurtBox.connect("area_entered", self, "on_hurtbox_enter")
	$Sprite.get_texture().region.position = Vector2(18, 0)
	create_death_particles()

func start():
	pass

func stop():
	stopped = true

func _process(_delta):
	if not alive or stopped:
		return

	register_inputs()
	var move_vector = Vector2.ZERO
	if inputs.size() > 0:
		move_vector = inputs[inputs.size()-1]
	if move_vector != prev_move_vector and move_vector != Vector2.ZERO:
		rotate_sprite(move_vector)
	velocity = move_and_slide(move_vector * game_speed * move_speed)
	
	if move_vector != Vector2.ZERO:
		prev_move_vector = move_vector

func register_inputs():
	var directions = {
		"press_left": Vector2.LEFT,
		"press_up": Vector2.UP,
		"press_right": Vector2.RIGHT,
		"press_down": Vector2.DOWN
	}
	for evt in directions.keys():
		if Input.is_action_just_pressed(evt) or Input.is_action_just_released(evt):
			var idx = inputs.find(directions[evt])
			if idx >= 0:
				inputs.remove(idx)
		if Input.is_action_just_pressed(evt):
			inputs.append(directions[evt])

func rotate_sprite(move_vector):
	var degrees = 0
	match move_vector:
		Vector2.LEFT:
			degrees = -90
		Vector2.RIGHT:
			degrees = 90
		Vector2.DOWN:
			degrees = 180
	set_rotation_degrees(degrees)

func set_game_speed(new_speed):
	for particle in $DeathParticles.get_children():
		particle.set_lifetime(particle.get_lifetime() * game_speed / new_speed)
		var material = particle.get_process_material()
		var init_velocity = material.get_param(ParticlesMaterial.PARAM_INITIAL_LINEAR_VELOCITY)
		material.set_param(ParticlesMaterial.PARAM_INITIAL_LINEAR_VELOCITY, init_velocity / game_speed * new_speed)
	$AudioSpeedController.set_game_speed(new_speed)
	game_speed = new_speed

func start_death_particles():
	for particle in $DeathParticles.get_children():
		particle.set_emitting(true)

func create_death_particles():
	for i in range(0, particle_amt):
		var angle = deg2rad((i+1) * int(360/particle_amt))
		var particle = death_particles.duplicate()
		var material = particle.get_process_material().duplicate()
		material.set_direction(Vector3(sin(angle), cos(angle), 0))
		particle.set_process_material(material)
		$DeathParticles.add_child(particle)
	
func on_hurtbox_enter(_a2d):
	if alive:
		$Sprite.get_texture().region.position = Vector2.ZERO
		start_death_particles()
		$AudioSpeedController.play()
		alive = false
		emit_signal("player_death")
