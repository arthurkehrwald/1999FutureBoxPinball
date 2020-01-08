extends Area

export var force = 10.0
export var score_value = 100

signal ball_bumped(new_score)

func _ready():
	connect("ball_bumped", GameState, "set_score")

func _on_Bumper_body_entered(body):
	body.set_linear_velocity(Vector3(0,0,0))
	body.apply_central_impulse((body.get_global_transform().origin - get_global_transform().origin).normalized() * force)
	emit_signal("ball_bumped", GameState.current_score + score_value)
