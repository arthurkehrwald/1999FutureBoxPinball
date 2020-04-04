class_name HitNotifier
extends CollisionObject
# Emits signals whenever the collision object it is attached to gets hit.

signal hit_by_pinball_directly(pos, vel)
signal hit_by_bomb_directly(pos, vel)
signal hit_by_missile_directly(pos, vel)
signal hit_by_bomb_explosion(pos, blast_radius)
signal hit_by_missile_explosion(pos, blast_radius)


func on_hit_by_pinball_directly(pos, vel):
	emit_signal("hit_by_pinball_directly", pos, vel)


func on_hit_by_bomb_directly(pos, vel):
	emit_signal("hit_by_bomb_directly", pos, vel)


func on_hit_by_missile_directly(pos, vel):
	emit_signal("hit_by_missile_directly", pos, vel)


func on_hit_by_bomb_explosion(pos, blast_radius):
	emit_signal("hit_by_bomb_explosion", pos, blast_radius)


func on_hit_by_missile_explosion(pos, blast_radius):
	emit_signal("hit_by_missile_explosion", pos, blast_radius)
