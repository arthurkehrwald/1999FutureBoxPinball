extends "res://Scripts/Damageable.gd"

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	connect("death", GameState, "on_Boss_death")
	
func _on_GameState_global_reset(_is_init):
	set_alive(true)

func _on_BossBombGun_was_hit_directly(impact_speed):
	take_damage(calc_damage(impact_speed))
