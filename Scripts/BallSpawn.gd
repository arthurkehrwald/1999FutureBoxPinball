extends Spatial

const BALL_SCENE = preload("res://Scenes/Pinball.tscn")

var accessible_balls = 0


func _ready():
	spawn_ball()


func spawn_ball():
	accessible_balls += 1
	var ball_instance = BALL_SCENE.instance()
	call_deferred("add_child", ball_instance)
	ball_instance.connect("accessibility_changed", self, "on_Ball_accessibility_changed")


func on_Ball_accessibility_changed(value):
	accessible_balls += 1 if value else -1
	print("accessible balls: ", accessible_balls)
	if accessible_balls < 1:
		spawn_ball()
