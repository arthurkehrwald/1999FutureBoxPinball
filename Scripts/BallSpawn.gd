extends Spatial

var ball_scene = preload("res://Scenes/Pinball.tscn")

func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")
	GameState.connect("spawn_ball", self, "spawn_ball")	
	GameState.ball_spawn_pos = get_global_transform().origin
	
func _on_GameState_stage_changed(new_stage, is_debug_skip):
	if is_debug_skip:
		spawn_ball()
	elif new_stage == GameState.EXPOSITION:
		spawn_ball()
		
func spawn_ball():
	var ball_instance = ball_scene.instance()
	add_child(ball_instance)
	var t = ball_instance.get_global_transform()
	t.origin = get_global_transform().origin
	ball_instance.set_global_transform(t)
	ball_instance.connect("became_inaccessible", self, "on_Ball_became_inaccessible")
	GameState.balls_on_field += 1

func on_Ball_became_inaccessible():
	print("BallSpawn: ball became inaccessible")
	print("BallSpawn: child count - ", get_child_count())
	for child in get_children():
		if child.is_in_group("Pinballs") and child.is_accessible_to_player:
			return
	spawn_ball()
