extends StaticBody

export var impact_velocity_damage_conversion_rate = 1.0
export var min_impact_velocity_for_damage = 5
export var max_impact_damage = 15
export var bomb_damage_taken = 20

func _ready():
	pass

func _process(_delta):
	pass

func _on_HitboxArea_body_entered(body):
	if body.get_linear_velocity().length() > min_impact_velocity_for_damage:
		var damage = min(max_impact_damage, body.get_linear_velocity().length() * impact_velocity_damage_conversion_rate)
		GameState.set_boss_health(GameState.boss_health - damage)
		
func _on_Bomb_explosion_hit():
	GameState.set_boss_health(GameState.boss_health - bomb_damage_taken)
