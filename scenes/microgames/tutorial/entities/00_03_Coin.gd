extends AnimatedSprite

func _ready():
	$PickupBox.connect("area_entered", self, "_on_area_entered")

func _on_area_entered(_a2d):
	$"/root/Helpers".play_sound_globally($PickupSFX)
	queue_free()
