extends "res://Scripts/Damageable.gd"

signal laser_trex_health_threshold_reached
signal black_hole_health_threshold_reached
signal solar_eclipse_health_threshold_reached

export var MISSILES_HEALTH_PERCENT = 80.0
export var LASER_TREX_HEALTH_PERCENT = 60.0
export var BLACK_HOLE_HEALTH_PERCENT = 40.0
export var SOLAR_ECLIPSE_HEALTH_PERCENT = 20.0


func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")
	connect("death", GameState, "on_Boss_death")


func _on_GameState_stage_changed(new_stage, is_debug_skip):
	match new_stage:
		GameState.stage.BOSS_BEGIN:
			print("Boss: bossfight began")
			set_active(true)
			$BossBombGun.set_shooting(true)
			
			yield(get_tree().create_timer($BossBombGun.SECONDS_BETWEEN_SHOTS * .5), "timeout")
			
			$BossBombGun2.set_shooting(true)
			$BossShield.set_active(true)
			$BossShield.set_visible(true)
			if is_debug_skip:
				$BossMissileGun.set_shooting(false)
		GameState.stage.SOLAR_ECLIPSE:
			if is_debug_skip:
				set_active(true)
				$BossBombGun.set_shooting(true)
				
				yield(get_tree().create_timer($BossBombGun.SECONDS_BETWEEN_SHOTS * .5), "timeout")
				
				$BossBombGun2.set_shooting(true)
				$BossMissileGun.set_shooting(true)
				$BossShield.set_active(true)
				$BossShield.set_visible(true)
		_:
			print("Boss: disabled based on stage")
			set_active(false)
			$BossBombGun.set_shooting(false)
			$BossBombGun2.set_shooting(false)
			$BossMissileGun.set_shooting(false)
			$BossShield.set_active(false)
			$BossShield.set_visible(false)
			$BossShield.set_process(false)


func _on_BossGun_was_hit_directly(impact_speed):
	if is_active:
		take_damage(calc_damage(impact_speed))

func _on_BossGun_was_hit_bomb_explosion():
	if is_active:
		take_damage(BOMB_EXPLOSION_DAMAGE)


func _on_is_active_changed():
	$HealthBar3D/Viewport/Bar.set_visible(is_active)


func _on_health_changed(old_health):
	print("Boss: health changed, current health = ", current_health, ", old health = ", old_health)
	$HealthBar3D/Viewport/Bar.update_value(current_health, MAX_HEALTH)
	if old_health / MAX_HEALTH * 100 > MISSILES_HEALTH_PERCENT:
		if current_health / MAX_HEALTH * 100 <= MISSILES_HEALTH_PERCENT:
			$BossMissileGun.set_shooting(true)
	if old_health / MAX_HEALTH * 100 > LASER_TREX_HEALTH_PERCENT:
		if current_health / MAX_HEALTH * 100 <= LASER_TREX_HEALTH_PERCENT:
			emit_signal("laser_trex_health_threshold_reached")
	if old_health / MAX_HEALTH * 100 > BLACK_HOLE_HEALTH_PERCENT:
		if current_health / MAX_HEALTH * 100 <= BLACK_HOLE_HEALTH_PERCENT:
			emit_signal("black_hole_health_threshold_reached")
	if old_health / MAX_HEALTH * 100 > SOLAR_ECLIPSE_HEALTH_PERCENT:
		if current_health / MAX_HEALTH * 100 <= SOLAR_ECLIPSE_HEALTH_PERCENT:
			emit_signal("solar_eclipse_health_threshold_reached")
