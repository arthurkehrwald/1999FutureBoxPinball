extends Spatial

const sens = Vector3(.125, .125, .005)

export var keyboard_input = false
export var discrete_input = true
export var clamped_input = false

var track = Vector3(0, 0, 1)

onready var wc = get_node("WebcamDummy")
onready var x_dummy = get_node("XDummy")
onready var y_dummy = get_node("YDummy")
onready var combo_dummy = get_node("ComboDummy")
onready var ds = get_node("DistanceSphere")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if not keyboard_input:
		sens.x *= .01
		sens.y *= .01


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP and event.pressed:
			track.z += sens.z
		elif event.button_index == BUTTON_WHEEL_DOWN and event.pressed:
			track.z -= sens.z
	elif not keyboard_input and event is InputEventMouseMotion and track.z != 0:
		track.x += event.relative.x * sens.x
		track.y += event.relative.y * sens.y
		var x_lim = track.z * PI
		track.x = clamp(track.x, -x_lim, x_lim)
		var y_lim = track.z * cos(track.x * track.z) * PI
		track.y = clamp(track.y, -y_lim, y_lim)


func _process(delta):
	if track.z == 0:
		return
	
	var old_track = track
	
	if keyboard_input:
		if discrete_input:
			if Input.is_action_just_pressed("ui_up"):
				track.y += sens.y * TAU
			if Input.is_action_just_pressed("ui_down"):
				track.y -= sens.y * TAU
			if Input.is_action_just_pressed("ui_right"):
				track.x += sens.x * TAU
			if Input.is_action_just_pressed("ui_left"):
				track.x -= sens.x * TAU
		else:
			if Input.is_action_pressed("ui_up"):
				track.y += sens.y * TAU * delta
			if Input.is_action_pressed("ui_down"):
				track.y -= sens.y * TAU * delta
			if Input.is_action_pressed("ui_right"):
				track.x += sens.x * TAU * delta
			if Input.is_action_pressed("ui_left"):
				track.x -= sens.x * TAU * delta
	
	if clamped_input:
		track.x = clamp(track.x, -PI * .25, PI * .25)
		track.y = clamp(track.y, -PI * .25, PI * .25)
	
	var wc_basis = wc.get_transform().basis.orthonormalized()
	
	var x_dummy_pos = wc.get_transform().origin
	x_dummy_pos += -wc_basis.z * track.z
	x_dummy_pos = x_dummy_pos.rotated(wc_basis.y, track.x)
	x_dummy.set_transform(Transform(Basis.IDENTITY, x_dummy_pos))
	
	var y_dummy_pos = wc.get_transform().origin
	y_dummy_pos += -wc_basis.z * track.z
	y_dummy_pos = y_dummy_pos.rotated(wc_basis.x, track.y)
	y_dummy.set_transform(Transform(Basis.IDENTITY, y_dummy_pos))
	
	var combo_dummy_pos = Vector3(x_dummy_pos.x, y_dummy_pos.y, 0)
	var combo_dummy_z_pos = sqrt(pow(track.z, 2) - pow(x_dummy_pos.x, 2) - pow(y_dummy_pos.y, 2))
	combo_dummy_pos += -wc_basis.z * combo_dummy_z_pos
	combo_dummy.set_transform(Transform(Basis.IDENTITY, combo_dummy_pos))

	ds.set_transform(Transform.IDENTITY.scaled(Vector3(track.z, track.z, track.z)))
