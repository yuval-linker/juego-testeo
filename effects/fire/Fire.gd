extends Area2D

onready var timer = $LifeTimer
onready var ray = $RayCast2D

func _ready() -> void:
	timer.connect("timeout", self, "_on_life_timeout")
	timer.start()
	connect("body_entered", self, "_on_body_entered")

func _physics_process(delta: float) -> void:
	if ray.is_colliding():
		queue_free()
	else:
		ray.enabled = false

func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		body.get_hurt(5)
		

func _on_life_timeout():
	queue_free()
