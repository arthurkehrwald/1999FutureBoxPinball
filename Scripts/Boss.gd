extends "res://Scripts/Damageable.gd"

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	connect("health_changed", GameState, "broadcast_boss_health")
	GameState.max_boss_health = max_health
	
func _on_GameState_global_reset():
	set_alive(true)
