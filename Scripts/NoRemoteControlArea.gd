class_name NoRemoteCotrolArea
extends Area
# Blocks remote control on any pinballs inside an area.
# Since remote control works with the same input as the
# flippers, this is useful near flippers, where the player likely
# wants to just hit the pinballs directly.

func _on_NoRemoteControlArea_body_entered(body):
	body.is_remote_control_blocked = true


func _on_NoRemoteControlArea_body_exited(body):
	body.is_remote_control_blocked = false
