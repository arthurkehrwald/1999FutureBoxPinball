extends Label

const format_string = "incline %s speed %s acceleration %s"

var max_value = 0
	
func _on_Ball_physics_debug_info_update(speed, gravity):
	text = format_string % [speed, gravity]

func display_debug_info(angle, speed, acceleration):
	text = format_string % [angle, speed, acceleration]
