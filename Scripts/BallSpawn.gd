extends Spatial

var ball_scene = preload("res://Scenes/Ball.tscn")

func _enter_tree():
	GameState.connect("spawn_ball", self, "_on_GameState_spawn_ball")

func _on_GameState_spawn_ball():
	var ball_instance = ball_scene.instance()
	add_child(ball_instance)
	var t = ball_instance.get_global_transform()
	t.origin = get_global_transform().origin
	ball_instance.set_global_transform(t)
	GameState.balls_on_field += 1
