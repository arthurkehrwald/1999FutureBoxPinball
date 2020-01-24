extends Area

export var strength = 10

func _on_MoonGate_body_entered(body):
	var angle = body.get_linear_velocity().normalized().angle_to(-get_transform().basis.z.normalized())
	print("MoonGate: ball entered at angle - ", angle)
	if angle < PI / 2:
		body.apply_central_impulse(-get_transform().basis.z.normalized() * strength)
