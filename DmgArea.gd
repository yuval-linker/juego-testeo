extends Area2D


func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body: Node):
	print(body.get_collision_layer_bit(0))
