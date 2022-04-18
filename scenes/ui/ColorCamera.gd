extends Node

export (Color, RGB) var background_color

func _ready():
	VisualServer.set_default_clear_color(background_color)
