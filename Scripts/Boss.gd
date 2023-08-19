class_name Boss
extends "res://Scripts/Damageable.gd"

signal is_active_changed(value)

export var BUMPER_CLUSTER_DMG_PER_BUMP = 1
export var is_active := false setget set_is_active
var was_is_active_set := false

func _enter_tree():
	Globals.boss = self

func _ready():
	connect("death", self, "_on_Self_death")
	# Wait for other scripts to connect
	yield(get_tree().create_timer(1.0), "timeout")
	set_is_active(is_active)

func set_is_active(value: bool):
	if was_is_active_set and value == is_active:
		return
	was_is_active_set = true
	is_active = value
	set_is_vulnerable(is_active)
	if is_active:
		set_health(MAX_HEALTH)
	emit_signal("is_active_changed", is_active)

func _on_Self_death():
	set_is_active(false)

func _on_BumperCluster_bumped(_bumper_cluster, _bumper, _bumped_body):
	take_damage(BUMPER_CLUSTER_DMG_PER_BUMP)
