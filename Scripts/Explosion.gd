extends Area

signal exploded

enum explosion_type {BOMB, MISSILE}
export(explosion_type) var type = explosion_type.BOMB

func explode():
	set_deferred("monitoring", true)
	set_deferred("monitorable", false)
	$Timer.start()
	$AudioStreamPlayer.play()
	yield($AudioStreamPlayer, "finished")
	emit_signal("exploded")

func _on_Explosion_body_entered(body):
	#print("Explosion hit: ", body.owner.name, " at pos: ", body.get_global_transform().origin)
	if not (type == explosion_type.MISSILE and body.is_in_group("Bombs")):		
		if body.has_method("on_Explosion_hit"):
			body.on_Explosion_hit(type, get_global_transform().origin)
		elif body.get_parent().has_method("on_Explosion_hit"):
			body.get_parent().on_Explosion_hit(type, get_global_transform().origin)
		
func _on_Timer_timeout():
	set_deferred("monitoring", false)
