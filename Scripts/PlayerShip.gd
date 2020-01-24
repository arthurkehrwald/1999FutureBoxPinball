extends "res://Scripts/Damageable.gd"

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	connect("health_changed", GameState, "broadcast_player_health")
	GameState.max_player_health = max_health

func _on_PlayerHitboxArea_body_entered(body):
	if body.get_collision_layer() == 1:
		GameState.on_PlayerShip_ball_drained(body)
		pass

func _on_GameState_global_reset():
	set_alive(true)
