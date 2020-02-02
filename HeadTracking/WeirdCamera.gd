extends Camera

func _process(_delta):
	set_frustum_offset(Vector2(get_transform().origin.x * -.31, get_transform().origin.z * .31))
	set_znear((get_transform().origin.y - 1) * .31)
