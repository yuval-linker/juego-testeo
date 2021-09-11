extends TextureButton

const CENTER = Vector2(640, 360)
const SIZE = 300
const ANGLE = deg2rad(-360.0/7)

export (Color) var color = Color(1, 1, 1, 1)

func _draw() -> void:
	draw_line(CENTER, CENTER + Vector2(SIZE, 0), color)
	draw_line(CENTER, CENTER + Vector2(cos(ANGLE)*SIZE, sin(ANGLE)*SIZE), color)
	draw_arc(CENTER, SIZE, 0, ANGLE, 100, color)
