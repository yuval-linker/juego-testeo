class_name Potion
extends Area2D


var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var linear_vel = Vector2.ZERO

onready var sprite = $Sprite


func _ready() -> void:
	var _error = connect("body_entered", self, "_on_body_entered")

func _physics_process(delta: float) -> void:
	position += linear_vel * delta
	linear_vel.y += GRAVITY * delta

func throw(direction):
	linear_vel = direction

func _on_body_entered(body: Node):
	queue_free()

func _on_screen_exited() -> void:
	queue_free()
