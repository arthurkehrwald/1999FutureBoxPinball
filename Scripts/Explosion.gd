class_name Explosion
extends Area
# Notifies any intersecting bodies / areas that are not hit by the ray cast.
# Deletes itself after a split second.

onready var _ray_cast = get_node("RayCast")


func _on_Explosion_body_entered(body):	
	_ray_cast.cast_to = body.owner.get_global_transform().origin - get_global_transform().origin
	_ray_cast.force_raycast_update()
	if !_ray_cast.is_colliding():
		if body.has_method("on_hit_by_explosion"):
			body.on_hit_by_explosion()


func _on_Timer_timeout():
	queue_free()
