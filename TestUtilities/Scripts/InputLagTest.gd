extends ColorRect

export var color_a := Color.white
export var color_b := Color.red

func _input(event):
	if event.is_action_pressed("debug_input_lag_test"):
		if color == color_a:
			color = color_b
		else:
			color = color_a
