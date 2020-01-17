extends Label

export var format_string = ""

var max_value = 0
	
func _on_Ball_physics_debug_info_update(speed, gravity):
	text = format_string % [speed, gravity]

func _on_PathFollow_angle_changed(angle):
	max_value = max(angle, max_value)
	text = format_string % [angle, max_value]
