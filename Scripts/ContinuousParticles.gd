extends Spatial

func set_is_emitting(value):
	for child in get_children():
		var particles = child as Particles
		if particles:
			particles.emitting = value
