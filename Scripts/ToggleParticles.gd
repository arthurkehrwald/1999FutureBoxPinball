extends Spatial


func toggle(value):
	for child in get_children():
		var particles = child as Particles
		if particles:
			particles.emitting = value
