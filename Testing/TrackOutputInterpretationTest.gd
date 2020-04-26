extends Spatial

const sens = Vector3(.001, .001, .01)

var track = Vector3(0, 0, 0)

onready var wc = get_node("WebcamDummy")
onready var t = get_node("TargetDummy")
onready var ds = get_node("DistanceSphere")
onready var tw = get_node("Tween")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#set_process(false)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP and event.pressed:
			track.z += sens.z
		elif event.button_index == BUTTON_WHEEL_DOWN and event.pressed:
			track.z -= sens.z
	elif event is InputEventMouseMotion and track.z != 0:
		track.x += event.relative.x * sens.x
		track.y += event.relative.y * sens.y
		var x_lim = track.z * PI
		track.x = clamp(track.x, -x_lim, x_lim)
		var y_lim = track.z * cos(track.x * track.z) * PI
		track.y = clamp(track.y, -y_lim, y_lim)
	elif event.is_action_pressed("toggle_head_tracking"):
		tw.interpolate_method(self, "apply_z", 0, track.z, 1,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tw.start()
		yield(get_tree().create_timer(1.0), "timeout")
		tw.interpolate_method(self, "apply_x", 0, track.x, 1,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tw.start()
		yield(get_tree().create_timer(1.0), "timeout")
		tw.interpolate_method(self, "apply_y", 0, track.y, 1,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)


func _process(_delta):
	if track.z == 0:
		return
	var wc_basis = wc.get_transform().basis.orthonormalized()
	var t_pos = wc.get_transform().origin
	#track.z = 1
	t_pos += -wc_basis.z * track.z
	t_pos = t_pos.rotated(wc_basis.y, track.z * track.x)
	var y_cross_radius = track.z * cos(track.x * track.z)
	t_pos = t_pos.rotated(wc_basis.x, y_cross_radius * track.y)
	t.set_transform(Transform(Basis.IDENTITY, t_pos))
	ds.set_transform(Transform.IDENTITY.scaled(Vector3(track.z, track.z, track.z)))


func apply_z(z):
	var wc_basis = wc.get_transform().basis.orthonormalized()
	var t_pos = wc.get_transform().origin
	t_pos -= wc_basis.z * z
	ds.set_transform(Transform.IDENTITY.scaled(Vector3(z, z, z)))
	t.set_transform(Transform(Basis.IDENTITY, t_pos))


func apply_x(x):
	var wc_basis = wc.get_transform().basis.orthonormalized()
	var t_pos = t.get_transform().origin
	var z = max(.01, track.z)
	t_pos = t_pos.rotated(wc_basis.y, z * x)
	t.set_transform(Transform(Basis.IDENTITY, t_pos))


func apply_y(y):
	var wc_basis = wc.get_transform().basis.orthonormalized()
	var t_pos = t.get_transform().origin
	var z = max(.01, track.z)
	t_pos = t_pos.rotated(wc_basis.x, 2 / z * y)
	t.set_transform(Transform(Basis.IDENTITY, t_pos))
