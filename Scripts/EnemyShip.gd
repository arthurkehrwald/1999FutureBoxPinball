extends "res://Scripts/Damageable.gd"

export var is_bumper = true
export var bump_force = 10.0

func _on_EnemyShip_death():
	set_active(false)
	
func _on_EnemyShip_came_to_life():
	set_active(true)

func set_active(is_active):
	$HitboxArea.set_deferred("monitoring", is_active)
	$HitboxArea.set_deferred("monitorable", is_active)
	set_visible(is_active)

func _on_EnemyShipHitboxArea_body_entered(body):
	body.set_linear_velocity(Vector3(0,0,0))
	body.apply_central_impulse((body.get_global_transform().origin - (get_global_transform().origin  + Vector3(0, .2, 0))).normalized() * bump_force)
