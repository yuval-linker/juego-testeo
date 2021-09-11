extends "res://real_potions/Potion.gd"

signal teleport(position)

func drink() -> void:
	.drink()
	player.set_collision_layer_bit(0, false)
	player.set_collision_mask_bit(4, false)
	player.twinkle = true

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("platforms"):
		player.position = global_position
		queue_free()

func _on_cooldown_finished() -> void:
	print("Destroyed!")
	player.twinkle = false
	player.set_collision_layer_bit(0, true)
	player.set_collision_mask_bit(4, true)
	queue_free()
