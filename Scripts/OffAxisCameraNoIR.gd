extends Camera

enum { TRACK_OFF, TRACK_CALIBRATING, TRACK_ON}

const TRACK_POS_FORMAT_STRING = "head tracking data:\nraw:\nx: %s\ny: %s\nz: %s"
const CALIBRATION_OFFSET = Vector3(5, -8, -8)

var track_raw_offset = Vector3(0, 0, 0)
var track_sensitivity = Vector3(0, 0, 0)
var track_cam_offset = Vector3(0, 0, 0)
var track_state = TRACK_OFF
var track_basis = Basis.IDENTITY

onready var track_state_debug_label = get_node("TrackStateDebugLabel")
onready var raw_offset_debug_label = get_node("RawOffsetDebugLabel")
onready var sensitivity_debug_label = get_node("SensitivityDebugLabel")
onready var cam_offset_debug_label = get_node("CamOffsetDebugLabel")
onready var tween = get_node("Tween")
onready var start_pos = get_global_transform().origin


func _ready():
	if Globals.head_track_cam_dummy != null:
		track_basis = Globals.head_track_cam_dummy.get_global_transform().basis
	else:
		push_warning("[WeirdCamera] can't find head track cam dummy. Face tracking will not work properly.")
	set_process_input(true)
	set_track_state(TRACK_OFF)


func _process(_delta):
	if track_state == TRACK_ON:
		track_cam_offset = track_raw_offset * track_sensitivity
		apply_offset(track_cam_offset)
	if track_state != TRACK_OFF:
		track_cam_offset = get_global_transform().origin - start_pos
		debug_output()
	
	set_frustum_offset(
			Vector2(get_transform().origin.x * -.31,
			get_transform().origin.z * .31)
			)
	set_znear((get_transform().origin.y - 1) * .31)


func _input(event):
	if current and event.is_action_pressed("toggle_head_tracking"):
		match track_state:
			TRACK_OFF:
				set_track_state(TRACK_CALIBRATING)
			TRACK_CALIBRATING:
				set_track_state(TRACK_ON)
			TRACK_ON:
				set_track_state(TRACK_OFF)
	
	if track_state == TRACK_OFF:
		return
	
	if event is InputEventMouseMotion:
		track_raw_offset.x += event.relative.x
		track_raw_offset.y += event.relative.y
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP and event.pressed:
			track_raw_offset.z += 1
		elif event.button_index == BUTTON_WHEEL_DOWN and event.pressed:
			track_raw_offset.z -= 1


func set_track_state(value):
	track_state = value
	match value:
		TRACK_OFF:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			tween.stop_all()
			set_global_transform(Transform(get_global_transform().basis, start_pos))
			track_state_debug_label.text = "head tracking: off"
			raw_offset_debug_label.text = ""
			sensitivity_debug_label.text = ""
			cam_offset_debug_label.text = ""
		TRACK_CALIBRATING:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			track_raw_offset = Vector3.ZERO
			track_sensitivity = Vector3.ZERO
			track_cam_offset = Vector3.ZERO
			set_global_transform(Transform(get_global_transform().basis, start_pos))
			track_state_debug_label.text = "head tracking: calibrating"
			tween.interpolate_method(self, "apply_offset", Vector3(0, 0, 0),
					CALIBRATION_OFFSET, 1, Tween.TRANS_LINEAR,
					Tween.EASE_IN_OUT)
			tween.start()
		TRACK_ON:
			tween.stop_all()
			track_state_debug_label.text = "head tracking: on"
#			var start_pos_in_track_basis = Transform(track_basis, start_pos)
#			var curr_pos_in_track_basis = Transform(track_basis, get_global_transform().origin)
#			var calib_offset_in_track_basis = curr_pos_in_track_basis.origin - start_pos_in_track_basis.origin
			track_sensitivity = CALIBRATION_OFFSET / track_raw_offset


func apply_offset(offset):
	var t = Transform(track_basis, start_pos)
	t = t.translated(offset)
	set_global_transform(Transform(get_global_transform().basis, t.origin))


func debug_output():
	raw_offset_debug_label.text = "raw offset\n%4.f\n%4.f\n%4.f" % [track_raw_offset.x,
			track_raw_offset.y, track_raw_offset.z]
	sensitivity_debug_label.text = "sensitivity\n%4.3f\n%4.3f\n%.3f" % [track_sensitivity.x,
			track_sensitivity.y, track_sensitivity.z]
	cam_offset_debug_label.text = "cam offset\n%2.1f\n%2.1f\n%2.1f" % [track_cam_offset.x,
			track_cam_offset.y, track_cam_offset.z]
