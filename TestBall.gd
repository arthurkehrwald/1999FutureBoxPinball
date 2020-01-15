extends "res://Scripts/Ball.gd"

var start_force = 20
var applied_force = true

func _ready():
	apply_central_impulse(-get_transform().basis.z.normalized() * start_force)

func _on_ResetTimer_timeout():
	teleport(start_pos, false, Vector3(0, 0, -1) * start_force)
