class_name Boss
extends Spatial

signal laser_trex_health_threshold_reached
signal black_hole_health_threshold_reached
signal ECLIPSE_health_threshold_reached

export var MISSILES_HEALTH_PERCENT = 80.0
export var LASER_TREX_HEALTH_PERCENT = 60.0
export var BLACK_HOLE_HEALTH_PERCENT = 40.0
export var ECLIPSE_HEALTH_PERCENT = 20.0

onready var _damageable = get_node("Damageable")
onready var _health_bar = get_node("HealthBar3D/Viewport/Bar")


func _enter_tree():
	GameState.connect("state_changed", self, "_on_GameState_changed")


func _ready():
	_damageable.connect("health_changed", self, "_on_Damageable_health_changed")
	_damageable.connect("health_changed", _health_bar, "update_value")
	_damageable.connect("is_vulnerable_changed", _health_bar, "set_visible")
	_damageable.connect("death", GameState, "handle_event", [GameState.Event.BOSS_DIED])


func _on_GameState_changed(new_state, is_debug_skip):
	match new_state:
		GameState.BOSS_BEGIN:
			_damageable.set_is_active(true)
			$BossBombGun.set_shooting(true)
			
			yield(get_tree().create_timer($BossBombGun.SECONDS_BETWEEN_SHOTS * .5), "timeout")
			
			$BossBombGun2.set_shooting(true)
			$BossShield.set_is_active(true)
			$BossShield.set_visible(true)
			if is_debug_skip:
				$BossMissileGun.set_shooting(false)
		GameState.ECLIPSE:
			if is_debug_skip:
				_damageable.set_is_vulnerable(true)
				$BossBombGun.set_shooting(true)
				
				yield(get_tree().create_timer($BossBombGun.SECONDS_BETWEEN_SHOTS * .5), "timeout")
				
				$BossBombGun2.set_shooting(true)
				$BossMissileGun.set_shooting(true)
				$BossShield.set_is_active(true)
				$BossShield.set_visible(true)
		_:
			print("Boss: disabled based on stage")
			_damageable.set_is_vulnerable(false)
			$BossBombGun.set_shooting(false)
			$BossBombGun2.set_shooting(false)
			$BossMissileGun.set_shooting(false)
			$BossShield.set_is_active(false)
			$BossShield.set_visible(false)
			$BossShield.set_process(false)


func _on_is_active_changed():
	$HealthBar3D/Viewport/Bar.set_visible(_damageable.is_vulnerable)


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
