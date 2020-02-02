extends "res://Scripts/Damageable.gd"

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	connect("death", GameState, "on_Boss_death")
	
func _on_GameState_global_reset(_is_init):
	set_alive(true)

func _on_BossGun_was_hit_directly(impact_speed):
	take_damage(calc_damage(impact_speed))

func _on_BossGun_was_hit_bomb_explosion():
	take_damage(bomb_explosion_damage)
