extends "res://Scripts/Damageable.gd"

signal money_changed(new_amount, is_maxed)

func _enter_tree():
	GameState.player_ship = self
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")
	connect("death_by_damage", GameState, "on_PlayerShip_death")

func _on_GameState_stage_changed(new_stage, is_debug_skip):
	if new_stage == GameState.stage.PREGAME or is_debug_skip:
		set_alive(true)

func _on_PlayerHitboxArea_body_entered(body):
	if body.is_in_group("Pinballs"):
		#GameState.on_PlayerShip_ball_drained(body, current_health)
		body.delete()
		pass

func _on_ShopMenu_bought_repair():
	set_health(max_health)

func _on_PlayerShip_death_by_damage():
	GameState.on_PlayerShip_death()
