extends Spatial

const BALL_SCENE = preload("res://Scenes/Pinball.tscn")

onready var spawn_delay_timer = get_node("SpawnDelayTimer")
var is_active := false setget set_is_active

func set_is_active(value: bool):
	if value == is_active:
		return
	is_active = value
	if is_active:
		ensure_one_accessible_ball()
	else:
		spawn_delay_timer.stop()

func _enter_tree():
	Globals.ball_spawn = self
	add_to_group("pinball_spawns")

func _ready():
	spawn_delay_timer.connect("timeout", self, "spawn_ball")
	set_is_active(true)


func spawn_ball():
	var ball_instance = BALL_SCENE.instance()
	ball_instance.set_global_transform(get_global_transform())
	get_node("/root").call_deferred("add_child", ball_instance)
	ball_instance.connect("became_inaccessible", self, "on_Pinball_became_inaccessible")


func ensure_one_accessible_ball():
	if not spawn_delay_timer.is_stopped():
		return
	for pinball in get_tree().get_nodes_in_group("pinballs"):
		pinball = pinball as Pinball
		if pinball.is_accessible_to_player:
			return
	spawn_delay_timer.start()


func on_Pinball_became_inaccessible():
	if is_active:
		ensure_one_accessible_ball()
