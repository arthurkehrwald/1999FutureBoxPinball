class_name Gate
extends StaticBody
# Can open and close a gate along with toggling a collision shape

export var anim_speed = 1.0

var is_open setget set_is_open


func _ready():
	$AnimationPlayer.set_speed_scale(anim_speed)


func set_is_open(value):
	$CollisionShape.set_deferred("disabled", value)
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.stop()
	if value:
		$AnimationPlayer.play("gate_slide_animation")
	else:
		$AnimationPlayer.play_backwards("gate_slide_animation")
