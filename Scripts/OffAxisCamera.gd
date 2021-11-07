extends Camera
class_name OffAxisCamera

export var zoom = .063;

var screen_center_child : Spatial = null


func _ready():
	cache_screen_center_child()


func _process(_delta):
	look_at_screen()
	var offset_from_screen_center = calc_offset_from_screen_center()
	update_projection(offset_from_screen_center)


func cache_screen_center_child():
	if Globals.screen_center_child == null:
		push_warning("[OffAxisCamera] Screen center child not set in globals."
				+ " Will use global origin as screen center position and"
				+ " identity as screen rotation.")
	else:
		screen_center_child = Globals.screen_center_child


func look_at_screen():
	if screen_center_child == null:
		return
	var local_rotation := Quat(Vector3(deg2rad(-90), 0, 0))
	screen_center_child.transform.basis = Basis(local_rotation)
	global_transform.basis = screen_center_child.global_transform.basis


func calc_offset_from_screen_center() -> Vector3:
	if screen_center_child == null:
		return global_transform.origin
	else:
		screen_center_child.global_transform.origin = global_transform.origin
		return screen_center_child.transform.origin


func update_projection(offset_from_screen_center : Vector3):
	set_frustum_offset(
			Vector2(offset_from_screen_center.x * -zoom,
			offset_from_screen_center.z * zoom)
			)
	set_znear((offset_from_screen_center.y) * zoom)
