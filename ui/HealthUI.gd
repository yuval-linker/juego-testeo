extends Control

onready var health = $Health

func set_player(player, player_name):
	player.connect("health_changed", self, "_on_health_change")
	$Label.text = player_name

func _on_health_change(new_health):
	health.value = new_health
