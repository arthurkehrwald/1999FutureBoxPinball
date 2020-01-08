extends Node

signal score_changed(new_score)
signal reserve_balls_changed(new_reserve_balls)
signal reset_ball
signal game_over

var current_score = 0 setget set_score
var reserve_balls = 3 setget set_reserve_balls

func set_score(new_score):
	new_score = max(0, new_score)
	current_score = new_score
	emit_signal("score_changed", current_score)

func set_reserve_balls(new_reserve_balls):
	new_reserve_balls = max(0, new_reserve_balls)
	reserve_balls = new_reserve_balls
	emit_signal("reserve_balls_changed", reserve_balls)

func _on_Drain_ball_drained():
	if reserve_balls > 0:
		set_reserve_balls(reserve_balls - 1)
		emit_signal("reset_ball")
	else:
		emit_signal("game_over")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
