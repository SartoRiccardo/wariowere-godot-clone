extends Node2D

signal succeeded
signal failed

export (float) var extend_amt = 50
export (float) var retract_time = 0.2

onready var start_arrow_pos = $Arrow.get_global_position()
onready var start_arrow_atlas = $Arrow/Sprite.get_texture().get_region()
onready var start_connect_arrow_rect = $ConnectArrow.get_region_rect()
onready var start_monitor_atlas = $Monitor.get_texture().get_region()

func move():
	var collision = $Arrow.move_and_collide(Vector2(-extend_amt, 0))
	var remainder_x = 0
	
	if collision:
		emit_signal("succeeded")
		$Clang.play()
		remainder_x = collision.remainder.x
	else:
		emit_signal("failed")
		$Fail.play()
		$Arrow/Sprite.texture.region.position.y += $Arrow/Sprite.texture.region.size.y
		$Monitor.texture.region.position.x += $Monitor.texture.region.size.x
		var timer = get_tree().create_timer(retract_time)
		timer.connect("timeout", self, "retract")
	
	$ConnectArrow.region_rect.size.x += extend_amt - remainder_x
	$ConnectArrow.offset.x = -$ConnectArrow.region_rect.size.x / 2

func retract():
	$Arrow.set_global_position(start_arrow_pos)
	$Arrow/Sprite.texture.set_region(start_arrow_atlas)
	$ConnectArrow.set_region_rect(start_connect_arrow_rect)
	$ConnectArrow.offset.x = -$ConnectArrow.region_rect.size.x / 2
	$Monitor.texture.set_region(start_monitor_atlas)
