extends StaticBody

signal ball_drained

func _enter_tree():
	connect("ball_drained", GameState, "_on_PlayerShip_ball_drained")

func _on_HitboxArea_body_entered(body):
	if body.name == "Ball":
		print("player hit")
		emit_signal("ball_drained")
