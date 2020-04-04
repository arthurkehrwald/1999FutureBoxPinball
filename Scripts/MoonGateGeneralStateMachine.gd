class_name MoonGateGeneralStateMachine
extends "res://Scripts/DamageableStateMachine.gd"
# Translates incoming events into inputs its states can interpret.

enum In{
	BOSSFIGHT_BEGAN,
	FLY_ANIM_FINISHED,
	DESTROYED
}


func _ready():
	_state.enter()


func on_hit_by_projectile(projectile):
	_state.handle_input(DamageIn.HIT_BY_PROJECTILE, {"projectile": projectile})
