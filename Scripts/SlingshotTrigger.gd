extends Area

export var force = 20

func _on_SlingshotTrigger_body_entered(body):
	body.set_linear_velocity(Vector3(0,0,0))
	body.apply_central_impulse(get_global_transform().basis.z.normalized() * force)