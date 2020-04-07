class_name Boss
extends Spatial

export var MISSILES_HEALTH_PERCENT = 80.0
export var LASER_TREX_HEALTH_PERCENT = 60.0
export var BLACK_HOLE_HEALTH_PERCENT = 40.0
export var ECLIPSE_HEALTH_PERCENT = 20.0

onready var _damageable = get_node("Damageable")
onready var _health_bar = get_node("HealthBar3D/Viewport/Bar")


func _ready():
	_damageable.connect("health_changed", self, "_on_Damageable_health_changed")
	_damageable.connect("health_changed", _health_bar, "update_value")
	_damageable.connect("is_vulnerable_changed", _health_bar, "set_visible")
	_damageable.connect("death", GameState, "handle_event", [GameState.Event.BOSS_DIED])


func _on_Damageable_health_changed(current_health, old_health, max_health):
	if old_health / max_health * 100 > MISSILES_HEALTH_PERCENT:
		if current_health / max_health * 100 <= MISSILES_HEALTH_PERCENT:
			GameState.handle_event(GameState.Event.BOSS_HEALTH_PASSED_MISSILES_THRESHOLD)
	if old_health / max_health * 100 > LASER_TREX_HEALTH_PERCENT:
		if current_health / max_health * 100 <= LASER_TREX_HEALTH_PERCENT:
			GameState.handle_event(GameState.Event.BOSS_HEALTH_PASSED_TREX_THRESHOLD)
	if old_health / max_health * 100 > BLACK_HOLE_HEALTH_PERCENT:
		if current_health / max_health * 100 <= BLACK_HOLE_HEALTH_PERCENT:
			GameState.handle_event(GameState.Event.BOSS_HEALTH_PASSED_BLACK_HOLE_THRESHOLD)
	if old_health / max_health * 100 > ECLIPSE_HEALTH_PERCENT:
		if current_health / max_health * 100 <= ECLIPSE_HEALTH_PERCENT:
			GameState.handle_event(GameState.Event.BOSS_HEALTH_PASSED_ECLIPSE_THRESHOLD)
