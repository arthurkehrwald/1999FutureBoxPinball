extends "res://Scripts/Damageable.gd"

func _enter_tree():
	GameState.connect("pregame_began", self, "set_alive", [false])
	GameState.connect("bossfight_began", self, "set_alive", [true])
	connect("death_by_damage", GameState, "on_Boss_death")

func _on_BossGun_was_hit_directly(impact_speed):
	take_damage(calc_damage(impact_speed))

func _on_BossGun_was_hit_bomb_explosion():
	take_damage(bomb_explosion_damage)

func _on_Boss_came_to_life():
	$Bar3D.set_visible(true)

func _on_Boss_death():
	$Bar3D.set_visible(false)
