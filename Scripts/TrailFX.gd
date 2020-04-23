extends Particles

const DENSITY = 10.0

onready var last_pos = get_global_transform().origin

#
#func _process(delta):
#	if emitting:
#		var speed = (last_pos - get_global_transform().origin).length() / delta
#		amount = max(1.0, speed * DENSITY)
#		last_pos = get_global_transform().origin
#		print("trailfx: speed - ", speed, " density - ", amount)


func _on_Timer_timeout():
	return
	if emitting:
		var speed = (last_pos - get_global_transform().origin).length()
		speed_scale = max(1.0, speed * DENSITY)
		last_pos = get_global_transform().origin
		print("trailfx: speed - ", speed, " density - ", speed_scale)
