class_name Boss
extends "res://Scripts/Damageable.gd"

export var BUMPER_CLUSTER_DMG_PER_BUMP = 1

func _enter_tree():
	Globals.boss = self


func _ready():
	connect("health_changed", self, "on_health_changed")


func _on_BumperCluster_bumped(_bumper_cluster, _bumper, _bumped_body):
	take_damage(BUMPER_CLUSTER_DMG_PER_BUMP)
