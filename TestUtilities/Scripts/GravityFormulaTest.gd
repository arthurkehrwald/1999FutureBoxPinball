extends Label

const E = 2.71828

export(float, 0, 20.0) var MAX_GRAV = 20.0
export(float, 0, 20.0) var MIN_GRAV = 5.0
export(float, 0, 1.0) var GRAV_CURVE_STEEPNESS = .5
export(float, 0, 1.0) var GRAV_CURVE_OFFSET = .5
export(float, 0, 50.0) var SPEED_LIM = 30.0

var input = 0.0


func _process(delta):
	if Input.is_action_pressed("ui_up"):
		input += delta * 5.0
	elif Input.is_action_pressed("ui_down"):
		input -= delta * 5.0
	var a = 5 / ((1 - GRAV_CURVE_STEEPNESS - .5 * (1 - GRAV_CURVE_STEEPNESS)) * SPEED_LIM)
	var b = input + (GRAV_CURVE_STEEPNESS * (1 - 2 * GRAV_CURVE_OFFSET) - 1) * SPEED_LIM * .5
	var out = (MIN_GRAV - MAX_GRAV) / (1 + pow(E, -a * b)) + MAX_GRAV
	text = "in = %s\nout = %s" % [input, out]
