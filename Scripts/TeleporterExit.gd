extends Spatial

export var exit_force_multiplier = 1
export var maintain_speed = true

func teleport_here(ball):
	var exit_impulse = get_global_transform().basis.z.normalized() * exit_force_multiplier
	if maintain_speed:
		exit_impulse *= ball.get_linear_velocity().length()
	ball.teleport(get_global_transform().origin)
	ball.add_central_impulse(exit_impulse)
