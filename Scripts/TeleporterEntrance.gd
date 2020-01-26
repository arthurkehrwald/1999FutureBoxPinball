extends Area

signal ball_entered(ball, teleporter_entrance)

func set_active(is_active):
	$CollisionShape.set_deferred("disabled", !is_active)

func _on_TeleporterEntrance_body_entered(body):
	emit_signal("ball_entered", body, self)
