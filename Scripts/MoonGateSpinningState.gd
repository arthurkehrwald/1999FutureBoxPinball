extends Spatial

onready var moon_gate = get_node("../..")

var spin_speed = 0.0
var spin_axis = Vector3(0, 0, 0)

func enter(var impact_body):
	moon_gate.movement_state = self
	var body_to_moon = moon_gate.get_global_transform().origin - impact_body.get_global_transform().origin
	spin_axis = impact_body.get_linear_velocity().cross(body_to_moon).normalized()
	var impact_speed = impact_body.get_linear_velocity().length()
	spin_speed = impact_speed * moon_gate.SPIN_SPEED_MULTIPLIER
	set_process(true)


func handle_input(var input, var opt_info = null):
	match input:
		moon_gate.In.IMPACT:
			assert(opt_info != null)
			enter(opt_info)


func exit():
	set_process(false)


func _process(delta):
	spin_speed -= moon_gate.SPIN_SPEED_FALLOFF * delta
	if spin_speed > 0:
		moon_gate.get_node("MeshInstance").set_transform(
			$MeshInstance.get_transform().rotated(spin_axis, spin_speed * delta))
	else:
		moon_gate.handle_input(moon_gate.In.STOPPED_SPINNING)
