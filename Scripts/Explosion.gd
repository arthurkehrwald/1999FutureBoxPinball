class_name Explosion
extends Area
# Notifies any intersecting bodies / areas that are not hit by the ray cast.
# Deletes itself after a split second.

const HITREG_DELAY = 0.1

onready var _blast_radius = get_node("CollisionShape").shape.radius
onready var _ray_cast = get_node("RayCast")
onready var _timer = get_node("Timer")


func _ready():
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.start(HITREG_DELAY)


func _is_behind_cover(var node):
	_ray_cast.cast_to = node.get_global_transform().origin - get_global_transform().origin
	_ray_cast.set_global_transform(Transform(Basis.IDENTITY, _ray_cast.get_global_transform().origin))
	_ray_cast.force_raycast_update()
	return _ray_cast.is_colliding() and _ray_cast.get_collider() != node


func _register_hits():
	for hit_area in get_overlapping_areas():
		if not _is_behind_cover(hit_area):
			_notify_hit_node(hit_area)
	for hit_body in get_overlapping_bodies():
		if not _is_behind_cover(hit_body):
			_notify_hit_node(hit_body)


func _on_Timer_timeout():
	_register_hits()
	queue_free()


func _notify_hit_node(_node):
	pass
