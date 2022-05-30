class_name Boss
extends "res://Scripts/Damageable.gd"

export var BUMPER_CLUSTER_DMG_PER_BUMP = 1
export var MISSILES_HEALTH_PERCENT = 50.0
export var LASER_TREX_HEALTH_PERCENT = 60.0
export var BLACK_HOLE_HEALTH_PERCENT = 40.0
export var ECLIPSE_HEALTH_PERCENT = 20.0

func _enter_tree():
	Globals.boss = self


func _ready():
	connect("health_changed", self, "on_health_changed")
	connect("death", GameState, "handle_event", [GameState.Event.BOSS_DIED])


func on_health_changed(current_health, old_health, max_health):
	if old_health / max_health * 100 > MISSILES_HEALTH_PERCENT:
		if current_health / max_health * 100 <= MISSILES_HEALTH_PERCENT:
			GameState.handle_event(GameState.Event.BOSS_MISSILES_THRESHOLD)
	if old_health / max_health * 100 > LASER_TREX_HEALTH_PERCENT:
		if current_health / max_health * 100 <= LASER_TREX_HEALTH_PERCENT:
			GameState.handle_event(GameState.Event.BOSS_TREX_THRESHOLD)
	if old_health / max_health * 100 > BLACK_HOLE_HEALTH_PERCENT:
		if current_health / max_health * 100 <= BLACK_HOLE_HEALTH_PERCENT:
			GameState.handle_event(GameState.Event.BOSS_BLACK_HOLE_THRESHOLD)
	if old_health / max_health * 100 > ECLIPSE_HEALTH_PERCENT:
		if current_health / max_health * 100 <= ECLIPSE_HEALTH_PERCENT:
			GameState.handle_event(GameState.Event.BOSS_ECLIPSE_THRESHOLD)


func on_GameState_changed(new_state, is_debug_skip):
	.on_GameState_changed(new_state, is_debug_skip)
	if is_debug_skip:
		match new_state:
			GameState.MISSILES_STATE:
				set_health(MAX_HEALTH * MISSILES_HEALTH_PERCENT * .01)
			GameState.TREX_STATE:
				set_health(MAX_HEALTH * LASER_TREX_HEALTH_PERCENT * .01)
			GameState.BLACK_HOLE_STATE:
				set_health(MAX_HEALTH * BLACK_HOLE_HEALTH_PERCENT * .01)
			GameState.ECLIPSE_STATE:
				set_health(MAX_HEALTH * ECLIPSE_HEALTH_PERCENT * .01)
			_:
				set_health(MAX_HEALTH)


func _on_BumperCluster_bumped(_bumper_cluster, _bumper, _bumped_body):
	take_damage(BUMPER_CLUSTER_DMG_PER_BUMP)
