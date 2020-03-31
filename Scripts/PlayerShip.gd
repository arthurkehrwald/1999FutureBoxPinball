extends "res://Scripts/Damageable.gd"

func _enter_tree():
	GameState.player_ship = self
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")
	connect("death", GameState, "on_PlayerShip_death")


func _on_GameState_stage_changed(new_stage, is_debug_skip):
	if new_stage == GameState.stage.PREGAME or is_debug_skip:
		set_active(true)


func _on_ShopMenu_bought_repair():
	set_health(MAX_HEALTH)


func _on_health_changed(old_health):
	if current_health < old_health:
		Announcer.say("ouch")
		$AudioStreamPlayer.play()
