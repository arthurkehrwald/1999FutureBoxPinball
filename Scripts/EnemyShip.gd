extends "res://Scripts/Damageable.gd"

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	GameState.connect("activate_enemy_ships", self, "_on_GameState_activate_enemy_ships")
	
func _ready():
	$HealthBar3D.set_max_health(max_health)

func _on_GameState_global_reset():
	set_alive(false)
	
func _on_GameState_activate_enemy_ships():
	set_alive(true)

func _on_EnemyShip_death():
	set_active(false)
	
func _on_EnemyShip_came_to_life():
	set_active(true)

func set_active(is_active):
	$CollisionShape.set_deferred("disabled", !is_active)
	$HitboxArea.set_deferred("monitoring", is_active)
	$HitboxArea.set_deferred("monitorable", is_active)
	set_visible(is_active)
