extends RigidBody

onready var target = get_node("../Target")


func look_follow(state, current_transform, target_position):
	print("ounth")
	var up_dir = Vector3(0, 1, 0)
	var cur_dir = current_transform.basis.xform(Vector3(0, 0, 1))
	var target_dir = (target_position - current_transform.origin).normalized()
	var rotation_angle = acos(cur_dir.x) - acos(target_dir.x)

	state.set_angular_velocity(up_dir * (rotation_angle / state.get_step()))

func _integrate_forces(state):
	var target_position = target.get_global_transform().origin
	look_follow(state, get_global_transform(), target_position)
