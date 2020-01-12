extends StaticBody

export var damage_multiplier = 1.0

func _on_HitboxArea_body_entered(body):
	if body.name == "Ball":
		var damage = body.get_linear_velocity().length() * damage_multiplier
		GameState.set_boss_health(GameState.boss_health - damage)
