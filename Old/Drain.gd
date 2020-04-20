extends Area

signal ball_drained

func _ready():
	connect("ball_drained", GameState, "_on_PlayerShip_ball_drained")
	pass

func _on_Drain_body_entered(body):
	emit_signal("ball_drained")
