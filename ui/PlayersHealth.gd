extends HBoxContainer

onready var HealthDisplay = preload("res://ui/HealthUI.tscn")

func _physics_process(delta: float) -> void:
	pass

func add_player(player, player_name) -> void:
	print("Adding player")
	var display = HealthDisplay.instance()
	display.set_player(player, player_name)
	add_child(display)
