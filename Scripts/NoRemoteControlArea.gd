class_name NoRemoteCotrolArea
extends Area
# Blocks remote control on any pinballs inside an area.
# Since remote control works with the same input as the
# flippers, this is useful near flippers, where the player likely
# wants to just hit the pinballs directly.


func _ready():
	connect("body_entered", self, "on_body_entered")
	connect("body_exited", self, "on_body_exited")


func on_body_entered(body):
	if body.is_in_group("pinballs"):
		body.is_remote_control_blocked = true


func on_body_exited(body):
	if body.is_in_group("pinballs"):
		body.is_remote_control_blocked = false
