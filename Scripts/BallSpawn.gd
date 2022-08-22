extends Spatial

const BALL_SCENE = preload("res://Scenes/Pinball.tscn")

onready var spawn_delay_timer = get_node("SpawnDelayTimer")
onready var insert_turret_delay_timer = get_node("InsertTurretDelayTimer")


func _enter_tree():
	Globals.ball_spawn = self


func _ready():
	spawn_delay_timer.connect("timeout", self, "spawn_ball")
	# TODO GameState.connect("state_changed", self, "on_GameState_changed")


func spawn_ball():
	var ball_instance = BALL_SCENE.instance()
	ball_instance.set_global_transform(get_global_transform())
	get_node("/root").call_deferred("add_child", ball_instance)
	ball_instance.connect("became_inaccessible", self, "on_Pinball_became_inaccessible")


func ensure_one_accessible_ball():
	if not spawn_delay_timer.is_stopped():
		return
	for pinball in get_tree().get_nodes_in_group("pinballs"):
		if pinball.is_accessible_to_player:
			return
	spawn_delay_timer.start()


func on_Pinball_became_inaccessible():
	if GameState.current_state != GameState.PREGAME_STATE:
		ensure_one_accessible_ball()


func on_GameState_changed(new_state, is_debug_skip):
	if new_state == GameState.PREGAME_STATE or is_debug_skip:
		spawn_delay_timer.stop()
		insert_turret_delay_timer.stop()
	if new_state != GameState.PREGAME_STATE and is_debug_skip:
		ensure_one_accessible_ball()
	if new_state == GameState.EXPOSITION_STATE or new_state == GameState.TESTING_STATE:
		spawn_delay_timer.start()
