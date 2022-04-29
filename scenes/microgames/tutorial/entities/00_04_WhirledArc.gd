tool
extends Node2D

export (float) var radius = 90

var game_speed = 1
var angle_values = {
	GE.Difficulty.EASY: 360/4,
	GE.Difficulty.MEDIUM: 360/8,
	GE.Difficulty.HARD: 360/16,
}
export (float) var angle = angle_values[GE.Difficulty.EASY]

func _ready():
	pass

func start():
	pass

func _process(_delta):
	if Engine.editor_hint:
		update()

func _draw():
	var points = draw_arc_polygon(radius, angle)
	$CollisionPolygon2D.set_polygon(points)

func draw_arc_polygon(radius, angle):
	var point_amt = (int(angle/90)+1) * 32.0
	var color = PoolColorArray([Color(1.0, 1.0, 1.0)])
	var points = PoolVector2Array()
	points.push_back(Vector2(0, 0))
	
	var current_angle = -angle/2
	for i in range(point_amt + 1):
		var angle_rad = deg2rad(current_angle)
		var point_pos = Vector2(cos(angle_rad), sin(angle_rad))
		points.append(point_pos * radius)
		current_angle += angle/point_amt
	draw_polygon(points, color)
	return points

func set_game_speed(new_speed):
	game_speed = new_speed

func set_difficulty(difficulty):
	angle = angle_values[difficulty]
	update()
