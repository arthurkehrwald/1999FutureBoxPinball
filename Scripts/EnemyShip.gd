extends "res://Scripts/Damageable.gd"

export var IS_BUMPER = true
export var BUMP_FORCE = 10.0

onready var collision_shape = get_node("CollisionShape")

func _on_is_active_changed():
	set_visible(is_active)
	collision_shape.set_deferred("disabled", not is_active)


func _on_impact(body):
	._on_impact(body)
	if (IS_BUMPER):
		body.set_linear_velocity(Vector3(0,0,0))
		body.apply_central_impulse((body.get_global_transform().origin - (get_global_transform().origin  + Vector3(0, .2, 0))).normalized() * BUMP_FORCE)


func _on_health_changed(old_health):
	$HealthBar3D.update_value(current_health, MAX_HEALTH)
	if current_health < old_health:
		$AudioStreamPlayer.play()
