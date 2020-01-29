extends Spatial

export var exit_force_multiplier = 1
export var maintain_speed = true

func _on_TeleporterEntrance_ball_entered(ball, _entrance):
	var exit_impulse = get_global_transform().basis.z.normalized() * exit_force_multiplier
	if maintain_speed:
		exit_impulse *= ball.get_linear_velocity().length()
	ball.delayed_teleport(get_global_transform().origin, exit_impulse)
