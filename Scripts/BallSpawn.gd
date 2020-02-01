extends Spatial

var ball_scene = preload("res://Scenes/Ball.tscn")

func _enter_tree():
	GameState.connect("exposition_began", self, "spawn_ball")
	GameState.connect("spawn_ball", self, "spawn_ball")	
	GameState.ball_spawn_pos = get_global_transform().origin
		
func spawn_ball():
	var ball_instance = ball_scene.instance()
	add_child(ball_instance)
	var t = ball_instance.get_global_transform()
	t.origin = get_global_transform().origin
	ball_instance.set_global_transform(t)
	GameState.balls_on_field += 1
