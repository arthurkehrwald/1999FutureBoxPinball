extends Area

func _ready():
	pass

func _on_NoRemoteControlArea_body_entered(body):
	if body.has_method("set_remote_control_blocked"):
		body.set_remote_control_blocked(true)

func _on_NoRemoteControlArea_body_exited(body):
	if body.has_method("set_remote_control_blocked"):
		body.set_remote_control_blocked(false)
