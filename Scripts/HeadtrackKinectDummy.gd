extends Spatial

export var enable_manual_calibration = false
export var move_speed = 1.0
export var rotateSpeed = 10.0
export var scale_speed = 10.0

func _ready():
	set_process(enable_manual_calibration)

func _process(delta):
	# manually finetune origin transform of kinect tracking data
	if Input.is_key_pressed(KEY_X) and not Input.is_key_pressed(KEY_CONTROL):
		if Input.is_key_pressed(KEY_SHIFT):
			global_translate(Vector3.LEFT * move_speed * delta)
		else:
			global_translate(Vector3.RIGHT * move_speed * delta)
	if Input.is_key_pressed(KEY_Y) and not Input.is_key_pressed(KEY_CONTROL):
		if Input.is_key_pressed(KEY_SHIFT):
			global_translate(Vector3.DOWN * move_speed * delta)
		else:
			global_translate(Vector3.UP * move_speed * delta)
	if Input.is_key_pressed(KEY_Z) and not Input.is_key_pressed(KEY_CONTROL):
		if Input.is_key_pressed(KEY_SHIFT):
			global_translate(Vector3.BACK * move_speed * delta)
		else:
			global_translate(Vector3.FORWARD * move_speed * delta)
	if Input.is_key_pressed(KEY_R):
		if Input.is_key_pressed(KEY_SHIFT):
			rotate_x(-rotateSpeed * delta)
		else:
			rotate_x(rotateSpeed * delta)
	if Input.is_key_pressed(KEY_X) and Input.is_key_pressed(KEY_CONTROL):
		if Input.is_key_pressed(KEY_SHIFT):
			scale -= Vector3.RIGHT * scale_speed * delta
		else:
			scale += Vector3.RIGHT * scale_speed * delta
	if Input.is_key_pressed(KEY_Y) and Input.is_key_pressed(KEY_CONTROL):
		if Input.is_key_pressed(KEY_SHIFT):
			scale -= Vector3.UP * scale_speed * delta
		else:
			scale += Vector3.UP * scale_speed * delta
	if Input.is_key_pressed(KEY_Z) and Input.is_key_pressed(KEY_CONTROL):
		if Input.is_key_pressed(KEY_SHIFT):
			scale -= Vector3.FORWARD * scale_speed * delta
		else:
			scale += Vector3.FORWARD * scale_speed * delta
