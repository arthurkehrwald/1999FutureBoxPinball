extends StaticBody

signal ball_drained

export var bomb_damage_taken = 30

func _enter_tree():
	connect("ball_drained", GameState, "_on_PlayerShip_ball_drained")

func _on_HitboxArea_body_entered(body):
	if body.name == "Ball":
		print("player hit")
		emit_signal("ball_drained")
		
func _on_Bomb_explosion_hit():
	GameState.set_player_health(GameState.player_health - bomb_damage_taken)
