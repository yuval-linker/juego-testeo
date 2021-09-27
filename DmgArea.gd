extends Area2D


func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body: Node):
	if body.has_method("damaged"):
		body.damaged(self, 5)
