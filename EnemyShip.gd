extends "res://Scripts/Bumper.gd"

export var max_health = 3
export var ball_damage = 1
export var bomb_damage = 1
export var bomb_explosion_damage = 3

var current_health = 0
var is_alive = true

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	GameState.connect("activate_enemy_ships", self, "_on_GameState_activate_enemy_ships")
	
func set_active(active):
	current_health = max_health
	is_alive = active
	set_monitoring(active)
	set_visible(active)
	
func _on_EnemyShip_body_entered(body):
	if body.get_collision_layer() == 1:
		current_health -= ball_damage
	else:
		current_health -= bomb_damage
	if current_health <= 0:
		set_active(false)

func _on_Bomb_explosion_hit():
	current_health -= bomb_explosion_damage
	if current_health <= 0:
		set_active(false)

func _on_GameState_global_reset():
	set_active(false)
	
func _on_GameState_activate_enemy_ships():
	set_active(true)
