extends Spatial

enum { TRACK_OFF, TRACK_CALIBRATING, TRACK_ON}

const START_OFFSET = Vector3(-PI / 16, 0, 22)
const CALIBRATION_OFFSET = Vector3(PI / 16, -PI / 16, 12)

var track_raw_offset = Vector3(0, 0, 0)
var track_sensitivity = Vector3(0, 0, 0)
var track_cam_offset = Vector3(0, 0, 0)
var track_state = TRACK_OFF

export var clamped_input = true
export (NodePath) var cam_path = ""

var track = Vector3(0, 0, 1)

onready var wc = get_node("WebcamDummy")
onready var x_dummy = get_node("XDummy")
onready var y_dummy = get_node("YDummy")
onready var combo_dummy = get_node("ComboDummy")
onready var ds = get_node("DistanceSphere")
onready var track_state_debug_label = get_node("TrackStateDebugLabel")
onready var raw_offset_debug_label = get_node("RawOffsetDebugLabel")
onready var sensitivity_debug_label = get_node("SensitivityDebugLabel")
onready var cam_offset_debug_label = get_node("CamOffsetDebugLabel")
onready var tween = get_node("Tween")
onready var cam = get_node_or_null(cam_path)


func _enter_tree():
	Globals.head_track_cam_dummy = self

func _ready():
	set_process_input(true)
	set_track_state(TRACK_OFF)


func _input(event):
	if cam and cam.current and event.is_action_pressed("toggle_head_tracking"):
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


func _process(_delta):
	if track_state == TRACK_ON:
		track_cam_offset = track_raw_offset * track_sensitivity
		apply_offset(START_OFFSET + track_cam_offset)
	if track_state != TRACK_OFF:
		debug_output()


func apply_offset(offset):
	if offset.z == 0:
		return
	
	if clamped_input:
		offset.x = clamp(offset.x, -PI * .25, PI * .25)
		offset.y = clamp(offset.y, -PI * .25, PI * .25)

	var wc_basis = wc.get_transform().basis.orthonormalized()
	
	var x_dummy_pos = wc.get_transform().origin
	x_dummy_pos += -wc_basis.z * offset.z
	x_dummy_pos = x_dummy_pos.rotated(wc_basis.y, offset.x)
	x_dummy.set_transform(Transform(Basis.IDENTITY, x_dummy_pos))

	var y_dummy_pos = wc.get_transform().origin
	y_dummy_pos += -wc_basis.z * offset.z
	y_dummy_pos = y_dummy_pos.rotated(wc_basis.x, offset.y)
	y_dummy.set_transform(Transform(Basis.IDENTITY, y_dummy_pos))

	var combo_dummy_pos = Vector3(x_dummy_pos.x, y_dummy_pos.y, 0)
	var combo_dummy_z_pos = sqrt(pow(offset.z, 2) - pow(x_dummy_pos.x, 2) - pow(y_dummy_pos.y, 2))
	combo_dummy_pos += -wc_basis.z * combo_dummy_z_pos
	combo_dummy.set_transform(Transform(Basis.IDENTITY, combo_dummy_pos))
	
	ds.set_transform(Transform.IDENTITY.scaled(Vector3(offset.z, offset.z, offset.z)))
	
	if cam != null:
		cam.set_pos(combo_dummy.get_global_transform().origin)
		#cam.set_global_transform(Transform(cam.get_global_transform().basis, combo_dummy.get_global_transform().origin))


func set_track_state(value):
	track_state = value
	match value:
		TRACK_OFF:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			tween.stop_all()
			apply_offset(START_OFFSET)
			track_state_debug_label.text = "head tracking: off"
			raw_offset_debug_label.text = ""
			sensitivity_debug_label.text = ""
			cam_offset_debug_label.text = ""
		TRACK_CALIBRATING:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			track_raw_offset = Vector3.ZERO
			track_sensitivity = Vector3.ZERO
			track_cam_offset = Vector3.ZERO
			track_state_debug_label.text = "head tracking: calibrating"
			tween.interpolate_method(self, "apply_offset", START_OFFSET,
					CALIBRATION_OFFSET, 1, Tween.TRANS_LINEAR,
					Tween.EASE_IN_OUT)
			tween.start()
		TRACK_ON:
			tween.stop_all()
			track_state_debug_label.text = "head tracking: on"
#			var start_pos_in_track_basis = Transform(track_basis, start_pos)
#			var curr_pos_in_track_basis = Transform(track_basis, get_global_transform().origin)
#			var calib_offset_in_track_basis = curr_pos_in_track_basis.origin - start_pos_in_track_basis.origin
			track_sensitivity = (CALIBRATION_OFFSET - START_OFFSET) / track_raw_offset


func debug_output():
	raw_offset_debug_label.text = "raw offset\n%4.f\n%4.f\n%4.f" % [track_raw_offset.x,
			track_raw_offset.y, track_raw_offset.z]
	sensitivity_debug_label.text = "sensitivity\n%4.3f\n%4.3f\n%.3f" % [track_sensitivity.x,
			track_sensitivity.y, track_sensitivity.z]
	cam_offset_debug_label.text = "cam offset\n%2.1f\n%2.1f\n%2.1f" % [track_cam_offset.x,
			track_cam_offset.y, track_cam_offset.z]
