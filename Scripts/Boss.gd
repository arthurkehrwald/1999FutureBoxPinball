extends "res://Scripts/Damageable.gd"

signal laser_trex_health_threshold_reached
signal black_hole_health_threshold_reached

export var missiles_health_percent = 80.0
export var laser_trex_health_percent = 60.0
export var black_hole_health_percent = 40.0

func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")
	connect("death_by_damage", GameState, "on_Boss_death")
	
func _on_GameState_stage_changed(new_stage, is_debug_skip):
	match new_stage:
		GameState.stage.BOSS_BEGIN:
			set_alive(true)
			$BossBombGun.set_firing(true)
			yield(get_tree().create_timer($BossBombGun.base_firing_rate * .5), "timeout")
			$BossBombGun2.set_firing(true)
			$BossShield.set_alive(true)
			$BossShield.set_visible(true)
		GameState.stage.SOLAR_ECLIPSE:
			if is_debug_skip:
				set_alive(true)
				$BossBombGun.set_firing(true)
				yield(get_tree().create_timer($BossBombGun.base_firing_rate * .5), "timeout")
				$BossBombGun2.set_firing(true)
				$BossMissileGun.set_firing(true)
				$BossShield.set_alive(true)
				$BossShield.set_visible(true)
		_:
			set_alive(false)
			$BossBombGun.set_firing(false)
			$BossBombGun2.set_firing(false)
			$BossMissileGun.set_firing(false)
			$BossShield.set_alive(false)
			$BossShield.set_visible(false)
			$BossShield.set_process(false)

func _on_BossGun_was_hit_directly(impact_speed):
	take_damage(calc_damage(impact_speed))

func _on_BossGun_was_hit_bomb_explosion():
	take_damage(bomb_explosion_damage)

func _on_Boss_came_to_life():
	$Bar3D.set_visible(true)

func _on_Boss_death():
	$Bar3D.set_visible(false)

func _on_Boss_health_changed(new_health, max_health, old_health):
	if not old_health / max_health * 100 <= missiles_health_percent:
		if new_health / max_health * 100 <= missiles_health_percent:
			$BossMissileGun.set_firing(true)
	if not old_health / max_health * 100 <= laser_trex_health_percent:
		if new_health / max_health * 100 <= laser_trex_health_percent:
			emit_signal("laser_trex_health_threshold_reached")
	if not old_health / max_health * 100 <= black_hole_health_percent:
		if new_health / max_health * 100 <= black_hole_health_percent:
			emit_signal("black_hole_health_threshold_reached")
	
