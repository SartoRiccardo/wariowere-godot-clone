extends AnimatedSprite

var active = true
var game_speed = 1

func set_game_speed(new_speed):
	set_speed_scale(new_speed)
	game_speed = new_speed

func die():
	active = false
	set_animation("dying")
	yield(self, "animation_finished")
	set_animation("dead")
	_on_death()

func gain():
	active = true
	set_animation("gaining")
	yield(self, "animation_finished")
	set_animation("alive")
	_on_gain()

func is_active():
	return active

# Override
func _on_death():
	pass

# Override
func _on_gain():
	pass
