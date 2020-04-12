extends Spatial

const BALL_SCENE = preload("res://Scenes/Pinball.tscn")

var accessible_balls = 0


func _ready():
	spawn_ball()


func spawn_ball():
	var ball_instance = BALL_SCENE.instance()
	add_child(ball_instance)
	var t = ball_instance.get_global_transform()
	t.origin = get_global_transform().origin
	ball_instance.set_global_transform(t)
	ball_instance.connect("became_inaccessible", self, "on_Ball_became_inaccessible")
	accessible_balls += 1


func on_Ball_became_inaccessible():
	accessible_balls -= 1
	if accessible_balls < 1:
		spawn_ball()
