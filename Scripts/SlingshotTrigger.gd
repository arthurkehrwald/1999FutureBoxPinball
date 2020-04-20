extends Area

export var BOUNCE_FORCE = 20

onready var audio_player = get_node("AudioStreamPlayer")


func _ready():
	connect("body_entered", self, "on_body_entered")


func on_body_entered(body):
	if not body.is_in_group("rollers"):
		return
	audio_player.play()
	body.set_linear_velocity(Vector3(0,0,0))
	body.apply_central_impulse(get_global_transform().basis.z.normalized() * BOUNCE_FORCE)
