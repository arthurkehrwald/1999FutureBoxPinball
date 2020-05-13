extends Spatial

const BALL_SCENE = preload("res://Scenes/Pinball.tscn")

var insert_next_ball_into_turret = false
var spawn_with_remote = false

onready var spawn_delay_timer = get_node("SpawnDelayTimer")
onready var insert_turret_delay_timer = get_node("InsertTurretDelayTimer")


func _enter_tree():
	Globals.ball_spawn = self


func _ready():
	if Globals.powerup_roulette != null:
		Globals.powerup_roulette.connect("selected_remote", self,
				"set_spawn_with_remote", [true])
		Globals.powerup_roulette.connect("remote_expired", self,
				"set_spawn_with_remote", [false])
	spawn_delay_timer.connect("timeout", self, "spawn_ball")
	GameState.connect("state_changed", self, "on_GameState_changed")


func spawn_ball():
	var ball_instance = BALL_SCENE.instance()
	ball_instance.set_global_transform(get_global_transform())
	get_node("/root").call_deferred("add_child", ball_instance)
	if spawn_with_remote:
		ball_instance.call_deferred("set_is_remote_controlled", true)
	if insert_next_ball_into_turret and Globals.player_turret != null:
		insert_turret_delay_timer.start()
		insert_turret_delay_timer.connect("timeout", Globals.player_turret,
		"insert_ball", [ball_instance], CONNECT_ONESHOT)
		insert_next_ball_into_turret = false
	ball_instance.connect("became_inaccessible", self, "on_Pinball_became_inaccessible")


func ensure_one_accessible_ball():
	if not spawn_delay_timer.is_stopped():
		return
	for pinball in get_tree().get_nodes_in_group("pinballs"):
		if pinball.is_accessible_to_player:
			return
	spawn_delay_timer.start()


func on_Pinball_became_inaccessible():
	if GameState.current_state != GameState.PREGAME:
		ensure_one_accessible_ball()


func set_spawn_with_remote(value):
	spawn_with_remote = value


func on_GameState_changed(new_state, is_debug_skip):
	if new_state == GameState.PREGAME or is_debug_skip:
		spawn_delay_timer.stop()
		insert_turret_delay_timer.stop()
		insert_next_ball_into_turret = false
		spawn_with_remote = false
	if new_state != GameState.PREGAME and is_debug_skip:
		ensure_one_accessible_ball()
	if new_state == GameState.EXPOSITION or new_state == GameState.TESTING:
		spawn_delay_timer.start()
