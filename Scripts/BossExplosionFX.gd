extends "res://Scripts/OneShotParticles.gd"

onready var anim_player = get_node("Spatial/AnimationPlayer")


func activate():
	.activate()
	anim_player.play("explode")
