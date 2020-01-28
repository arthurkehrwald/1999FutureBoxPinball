extends "res://Scripts/Damageable.gd"

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	connect("death", GameState, "on_Boss_death")
	
func _ready():
	$HealthBar.max_value = max_health
	
func _on_GameState_global_reset(_is_init):
	set_alive(true)
