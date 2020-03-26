extends "res://Scripts/Damageable.gd"

export var IS_BUMPER = true
export var BUMP_FORCE = 10.0


func _on_is_active_changed():
	$HitboxArea.set_deferred("monitoring", is_active)
	$HitboxArea.set_deferred("monitorable", is_active)
	set_visible(is_active)


func _on_EnemyShipHitboxArea_body_entered(body):
	if (IS_BUMPER):
		body.set_linear_velocity(Vector3(0,0,0))
		body.apply_central_impulse((body.get_global_transform().origin - (get_global_transform().origin  + Vector3(0, .2, 0))).normalized() * BUMP_FORCE)


func _on_health_changed(old_health):
	$HealthBar3D.update_value(current_health, MAX_HEALTH)
	if current_health < old_health:
		$AudioStreamPlayer.play()
