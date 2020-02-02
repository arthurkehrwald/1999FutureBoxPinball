extends Area

enum explosion_type {BOMB, MISSILE}
var method_to_call = ""
		
func init(type):
	match type:
		explosion_type.BOMB:
			method_to_call = "_on_Bomb_explosion_hit"
		explosion_type.MISSILE:
			method_to_call = "_on_Missile_explosion_hit"
	monitorable = true
	monitoring = true
	$Timer.start()

func _on_Explosion_body_entered(body):
	$RayCast.cast_to = get_global_transform().origin - body.get_global_transform().origin
	$RayCast.force_raycast_update()
	$RayCast.enabled = true
	if !$RayCast.is_colliding():
		if body.has_method(method_to_call):
			body._on_Bomb_explosion_hit()
		elif body.owner.has_method(method_to_call):
			body.owner._on_Bomb_explosion_hit()

func _on_Timer_timeout():
	queue_free()
