extends Label

var format_string = "Speed: %s Gravity Scale: %s"
	
func _on_Ball_physics_debug_info_update(speed, gravity):
	text = format_string % [speed, gravity]
