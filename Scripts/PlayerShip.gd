extends "res://Scripts/Damageable.gd"

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	connect("death", GameState, "on_PlayerShip_death")
	
func _ready():
	$HealthBar.max_value = max_health

func _on_PlayerHitboxArea_body_entered(body):
	if body.get_collision_layer() == 1:
		print(body.name)
		GameState.on_PlayerShip_ball_drained(body, current_health)
		pass

func _on_GameState_global_reset():
	set_alive(true)
