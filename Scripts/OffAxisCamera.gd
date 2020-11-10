tool
extends Camera

export var adjustment = .324;

func _process(_delta):
	set_frustum_offset(
			Vector2(get_transform().origin.x * -adjustment,
			get_transform().origin.z * adjustment)
			)
	set_znear((get_transform().origin.y - 1) * .32)
