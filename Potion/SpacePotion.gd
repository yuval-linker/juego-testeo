extends Area2D

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")

var linear_vel = Vector2.ZERO
var TILE_OFFSET = 16
onready var cooldown = $DrinkCooldown
var player

signal teleport(position)

func _ready() -> void:
	var _error = connect("body_entered", self, "_on_body_entered")
	$VisibilityNotifier2D.connect("screen_exited", self, "_on_screen_exited")
	cooldown.connect("timeout", self, "_on_cooldown_finished")

func _physics_process(delta: float) -> void:
	position += linear_vel * delta
	linear_vel.y += GRAVITY * delta

func throw(direction):
	linear_vel = direction

func _destroy():
	player.potion_index -= 1
	queue_free()

func _on_body_entered(body: Node2D):
	if body.is_in_group("platforms"):
		emit_signal("teleport", global_position)
		_destroy()

func _on_screen_exited() -> void:
	_destroy()

func drink(caller: KinematicBody2D):
	$Sprite.visible = false
	$CollisionShape2D.disabled = true
	player = caller
	cooldown.start()
	player.set_collision_layer_bit(0, false)
	player.set_collision_mask_bit(4, false)
	player.twinkle = true

func _on_cooldown_finished():
	print("Destroyed!")
	player.twinkle = false
	player.set_collision_layer_bit(0, true)
	player.set_collision_mask_bit(4, true)
	queue_free()
