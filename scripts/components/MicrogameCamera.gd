tool
extends Camera2D

export (bool) var debug_gui_visible = false
export (Vector2) var microgame_window_size = Vector2(200, 130)
export (Color, RGB) var background_color
export (Color, RGB) var background_color_checkers
export (Color, RGB) var microgame_background_color = Color(0)

onready var background = $CanvasLayer/Background
onready var game_container = $CanvasLayer/Background/GameContainer
onready var bomb = $BombCanvasLayer/Bomb
onready var bomb_exploded = $CanvasLayer/Background/BombExploded

func _ready():
	if Engine.editor_hint:
		return
	
	background.set_visible(true)
	
	var shader = background.get_material()
	shader.set_shader_param("panel_size", background.rect_size)
	var border_width = game_container.get_stylebox("panel").border_width_top
	shader.set_shader_param("hole_size", microgame_window_size - Vector2(border_width-1, border_width-1)*2)
	shader.set_shader_param("background_color", Vector3(background_color.r, background_color.g, background_color.b))
	shader.set_shader_param("background_color_checkers", Vector3(background_color_checkers.r, background_color_checkers.g, background_color_checkers.b))
	background.set_material(shader)
	
	var bomb = $"/root/Helpers".get_bomb()
	if bomb:
		bomb.connect("explode", self, "on_microgame_timeout")
	
	VisualServer.set_default_clear_color(microgame_background_color)
	game_container.set_custom_minimum_size(microgame_window_size)
	$Line2D.hide()

func _process(_delta):
	if Engine.editor_hint:
		process_editor()
		return

func process_editor():
	if debug_gui_visible and not $CanvasLayer/Background.is_visible():
		$CanvasLayer/Background.set_visible(true)
	elif not debug_gui_visible and $CanvasLayer/Background.is_visible():
		$CanvasLayer/Background.set_visible(false)
	
	var camera_size = $CanvasLayer/Background.rect_size
	var first_point = (camera_size - microgame_window_size) / 2
	var points = [
		Vector2.ZERO, Vector2(microgame_window_size.x, 0),
		microgame_window_size, Vector2(0, microgame_window_size.y),
		Vector2.ZERO
	]
	for i in range(points.size()):
		var p = points[i]
		points[i] = (p + first_point - camera_size/2) * zoom
	$Line2D.set_points(PoolVector2Array(points))

func explode_bomb():
	bomb.hide()
	bomb_exploded.show()

func set_game_speed(speed):
	bomb.set_game_speed(speed)

func on_microgame_timeout():
	explode_bomb()
