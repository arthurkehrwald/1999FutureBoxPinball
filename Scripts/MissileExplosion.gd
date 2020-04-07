extends "res://Scripts/Explosion.gd"

func _notify_hit_node(var node):
	if node.has_method("on_hit_by_missile_explosion"):
		node.on_hit_by_missile_explosion(get_global_transform().origin, _blast_radius)
