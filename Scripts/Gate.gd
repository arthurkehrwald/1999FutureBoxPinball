extends StaticBody

export var anim_speed = 1.0

func _ready():
	$AnimationPlayer.set_speed_scale(anim_speed)

func set_open(is_open):
	$CollisionShape.set_deferred("disabled", is_open)
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.stop()
	if is_open:
		$AnimationPlayer.play("gate_slide_animation")
	else:
		$AnimationPlayer.play_backwards("gate_slide_animation")
