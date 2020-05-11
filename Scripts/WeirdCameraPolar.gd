extends Camera


func set_pos(pos):
	set_global_transform(Transform(get_global_transform().basis, pos))
	
	set_frustum_offset(
			Vector2(get_transform().origin.x * -.31,
			get_transform().origin.z * .31)
			)
	set_znear((get_transform().origin.y - 1) * .31)
