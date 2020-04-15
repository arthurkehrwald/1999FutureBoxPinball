class_name Explosion
extends Area
# Notifies any intersecting bodies / areas that are not hit by the ray cast.
# Deletes itself after a split second.

const LIFETIME = 0.1

var has_hit_player_or_flipper = false

onready var blast_radius = get_node("CollisionShape").shape.radius
onready var hitreg_raycast = get_node("HitregRaycast")
onready var self_delete_timer = get_node("SelfDeleteTimer")


func _ready():
	self_delete_timer.connect("timeout", self, "on_SelfDeleteTimer_timeout")
	self_delete_timer.start(LIFETIME)


func is_behind_cover(var node):
	hitreg_raycast.cast_to = node.get_global_transform().origin - get_global_transform().origin
	hitreg_raycast.set_global_transform(Transform(Basis.IDENTITY, hitreg_raycast.get_global_transform().origin))
	hitreg_raycast.force_raycast_update()
	return hitreg_raycast.is_colliding() and hitreg_raycast.get_collider() != node


func register_hits():
	for hit_object in get_overlapping_bodies() + get_overlapping_areas():
		if not is_behind_cover(hit_object):
			if hit_object.has_method("on_hit_by_explosion"):
				if hit_object.is_in_group("flippers") or hit_object == Globals.player_ship:
					if not has_hit_player_or_flipper:
						has_hit_player_or_flipper = true
						hit_object.on_hit_by_explosion(self)
				else:
					hit_object.on_hit_by_explosion(self)


func on_SelfDeleteTimer_timeout():
	register_hits()
	queue_free()
