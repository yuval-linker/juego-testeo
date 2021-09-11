extends TileMap

func get_tile_pos(coll_pos: Vector2) -> Vector2:
	return map_to_world(world_to_map(coll_pos))
