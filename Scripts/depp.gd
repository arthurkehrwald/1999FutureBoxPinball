extends Area

export var strength = 1.0

func _on_MoonGate_body_entered(body):
	var angle = body.get_linear_velocity().normalized().angle_to(-get_transform().basis.z.normalized())
	print("MoonGate: ball entered at angle - ", angle)
	if angle < PI / 2:
		$AnimationPlayer.play("moon_spectral_transition")
		body.apply_central_impulse(-get_transform().basis.z.normalized() * strength)
