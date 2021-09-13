extends Area2D

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var linear_vel = Vector2.ZERO
var _disabled = false
var player

onready var cooldown = $DrinkCooldown
onready var visibility_notify = $VisibilityNotifier2D

func _ready() -> void:
	var _error = connect("body_entered", self, "_on_body_entered")
	cooldown.connect("timeout", self, "_on_cooldown_finished")
	visibility_notify.connect("screen_exited", self, "_on_screen_exited")

func _physics_process(delta: float) -> void:
	position += linear_vel * delta
	linear_vel.y += GRAVITY * delta

func throw(direction):
	linear_vel = direction

func drink():
	disable()
	cooldown.start()

func disable() -> void:
	$Sprite.visible = false
	$CollisionShape2D.disabled = true
	_disabled = true

func enable() -> void:
	$Sprite.visible = true
	$CollisionShape2D.disabled = false
	_disabled = false

func _destroy():
	player.potion_index -= 1
	queue_free()

# Signal callbacks
func _on_body_entered(body: Node):
	if body != player:
		_destroy()

func _on_screen_exited() -> void:
	if not _disabled:
		_destroy()

func _on_cooldown_finished() -> void:
	_destroy()
