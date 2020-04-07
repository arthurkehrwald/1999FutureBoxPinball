extends "res://Scripts/Explosion.gd"

func _notify_hit_node(node):
	if node.has_method("on_hit_by_bomb_explosion"):
		node.on_hit_by_bomb_explosion(get_global_transform().origin, _blast_radius)
