class_name InvisibleButtonPlunger
extends Area

export var IMPULSE_STRENGTH = 20.0

var rollers_in_area = []

func _ready():
	add_to_group("plunger")
	connect("body_entered", self, "on_body_entered")
	connect("body_exited", self, "on_body_exited")


func on_body_entered(body):
	if not body.is_in_group("rollers"):
		return
	if not body is RigidBody:
		return
	if rollers_in_area.has(body):
		return
	rollers_in_area.push_back(body)


func on_body_exited(body):
	if rollers_in_area.has(body):
		rollers_in_area.erase(body)


func _process(_delta):
	if Input.is_action_just_pressed("plunger"):
		launch_all()


func launch_all():
	for roller in rollers_in_area:
		var dir = -global_transform.basis.z
		roller.apply_central_impulse(dir * IMPULSE_STRENGTH)
	rollers_in_area.clear()
