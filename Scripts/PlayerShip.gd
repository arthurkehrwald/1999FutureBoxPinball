extends StaticBody

export var bomb_damage_taken = 30

func _on_HitboxArea_body_entered(body):
	if body.get_collision_layer() == 1:
		GameState._on_PlayerShip_ball_drained(body)
		
func _on_Bomb_explosion_hit():
	GameState.set_player_health(GameState.player_health - bomb_damage_taken)
