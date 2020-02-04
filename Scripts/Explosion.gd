extends Area

signal exploded

enum explosion_type {BOMB, MISSILE}
export(explosion_type) var type = explosion_type.BOMB

func explode():
	set_deferred("monitoring", true)
	set_deferred("monitorable", false)
	$Timer.start()

func _on_Explosion_body_entered(body):
	print("Explosion hit: ", body.owner.name, " at pos: ", body.get_global_transform().origin)
	if not (type == explosion_type.MISSILE and body.get_collision_layer_bit(10)):		
		if body.has_method("on_Explosion_hit"):
			body.on_Explosion_hit(type, get_global_transform().origin)
		elif body.owner.has_method("on_Explosion_hit"):
			body.owner.on_Explosion_hit(type, get_global_transform().origin)
		
func _on_Timer_timeout():
	emit_signal("exploded")
	queue_free()
