extends Spatial

const BALL_SCENE = preload("res://Scenes/Pinball.tscn")

var accessible_balls = 0

onready var spawn_delay_timer = get_node("SpawnDelayTimer")


func _ready():
	spawn_delay_timer.connect("timeout", self, "on_SpawnDelayTimer_timeout")
	spawn_delay_timer.start()


func spawn_ball():
	accessible_balls += 1
	var ball_instance = BALL_SCENE.instance()
	ball_instance.set_global_transform(get_global_transform())
	get_node("/root").call_deferred("add_child", ball_instance)
	ball_instance.connect("accessibility_changed", self, "on_Ball_accessibility_changed")


func on_Ball_accessibility_changed(value):
	accessible_balls += 1 if value else -1
	if accessible_balls < 1:
		spawn_delay_timer.start()


func on_SpawnDelayTimer_timeout():
	spawn_ball()
