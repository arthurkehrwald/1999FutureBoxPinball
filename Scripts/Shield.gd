class_name Shield
extends "res://Scripts/Damageable.gd"

export var REGENERATES = false
export var REGENERATION_TIME = 10.0

onready var health_bar = get_parent().get_node("BossBar3D/Viewport/BossBar/ShieldBar")

onready var regeneration_timer = get_node("RegenerationTimer")
onready var front_area = get_node("FrontArea")
onready var behind_area = get_node("BehindArea")
onready var col_layers_when_enabled = call("get_collision_layer")


func _ready():
	connect("is_vulnerable_changed", self, "on_is_vulnerable_changed")
	connect("death", self, "on_death")
	connect("health_changed", health_bar, "update_value")
	regeneration_timer.connect("timeout", self, "on_RegenerationTimer_timeout")
	front_area.connect("body_exited", self, "on_FrontArea_body_exited")
	behind_area.connect("body_entered", self, "on_BehindArea_body_entered")
	set_visible(false)


func on_is_vulnerable_changed(value):
	if value:
		set_visible(value)
	call("set_collision_layer", col_layers_when_enabled if value else 0)
	front_area.set_deferred("monitoring", value)
	behind_area.set_deferred("monitoring", value)


func on_death():
	if REGENERATES:
		regeneration_timer.start(REGENERATION_TIME)


func on_RegenerationTimer_timeout():
	set_health(MAX_HEALTH)
	set_is_vulnerable(true)


func on_FrontArea_body_entered(body):
	if !body.get_colliding_bodies().has(self):
		call("remove_collision_exception_with", body)
		body.remove_collision_exception_with(self)


func on_FrontArea_body_exited(body):
	call("remove_collision_exception_with", body)
	body.remove_collision_exception_with(self)


func on_BehindArea_body_entered(body):
	call("add_collision_exception_with", body)
	body.add_collision_exception_with(self)
