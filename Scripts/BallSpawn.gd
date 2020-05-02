extends Spatial

const BALL_SCENE = preload("res://Scenes/Pinball.tscn")

var accessible_balls = []
var insert_next_ball_into_turret = false
var is_next_ball_remote_controlled = false

onready var spawn_delay_timer = get_node("SpawnDelayTimer")


func _ready():
	if Globals.powerup_roulette != null:
		Globals.powerup_roulette.connect("selected_turret_on_deleted_ball", self,
				"on_PowerupRoulette_selected_turret_on_deleted_ball")
		Globals.powerup_roulette.connect("selected_remote_on_deleted_ball", self,
				 "on_PowerupRoulette_selected_remote_on_deleted_ball")
	spawn_delay_timer.connect("timeout", self, "on_SpawnDelayTimer_timeout")
	spawn_delay_timer.start()
	GameState.connect("state_changed", self, "on_GameState_changed")


func spawn_ball():
	var ball_instance = BALL_SCENE.instance()
	ball_instance.set_global_transform(get_global_transform())
	get_node("/root").call_deferred("add_child", ball_instance)
	if is_next_ball_remote_controlled:
		ball_instance.call_deferred("set_is_remote_controlled", true)
		is_next_ball_remote_controlled = false
	if insert_next_ball_into_turret and Globals.player_turret != null:
		Globals.player_turret.insert_ball(ball_instance)
		insert_next_ball_into_turret = false
	ball_instance.connect("accessibility_changed", self, "on_Ball_accessibility_changed")
	accessible_balls.push_back(ball_instance)


func on_Ball_accessibility_changed(pinball, value):
	if value:
		accessible_balls.push_back(pinball)
	else:
		accessible_balls.erase(pinball)
	if accessible_balls.size() < 1:
		spawn_delay_timer.start()


func on_SpawnDelayTimer_timeout():
	spawn_ball()


func on_PowerupRoulette_selected_turret_on_deleted_ball():
	if accessible_balls.size() > 0 and Globals.player_turret != null:
		Globals.player_turret.insert_ball(accessible_balls[0])
	else:
		insert_next_ball_into_turret = true


func on_PowerupRoulette_selected_remote_on_deleted_ball():
	if accessible_balls.size() > 0:
		accessible_balls[0].set_is_remote_controlled(true)
	else:
		is_next_ball_remote_controlled = true


func on_GameState_changed(new_state, is_debug_skip):
	if new_state == GameState.PREGAME or is_debug_skip:
		insert_next_ball_into_turret = false
		is_next_ball_remote_controlled = false
