extends KinematicBody

export var IS_RIGHT_FLIPPER = false
export var MAX_TURN_ANGLE = 60
export var TURN_SPEED = 500

var start_transform = Transform()
var max_transform = Transform()
var rotation_progress = 0.0
var input_code = ""

func _ready():	
	start_transform = get_transform()	
	if IS_RIGHT_FLIPPER:
		input_code = "ui_right"
		max_transform = start_transform.rotated(get_transform().basis.y.normalized(), deg2rad(-MAX_TURN_ANGLE))
	else:
		input_code = "ui_left"
		max_transform = start_transform.rotated(get_transform().basis.y.normalized(), deg2rad(MAX_TURN_ANGLE))

func _physics_process(delta):	
	if Input.is_action_pressed(input_code):
		if rotation_progress < 1:
			rotation_progress += TURN_SPEED / MAX_TURN_ANGLE * delta
	elif rotation_progress > 0:
		rotation_progress -= TURN_SPEED / MAX_TURN_ANGLE * delta
	
	var new_rotation = Quat(start_transform.basis.orthonormalized()).slerp(max_transform.basis.orthonormalized(), rotation_progress)
	set_transform(Transform(new_rotation, get_transform().origin))
