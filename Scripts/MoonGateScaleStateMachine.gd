class_name MoonGateScaleStateMachine
extends "res://Scripts/StateMachine.gd"
# Translates incoming events into inputs its states can interpret.

enum In{
	DAMAGED,
	SCALE_ANIM_DONE,
	FLY_ANIM_DONE,
	STOPPED_SPINNING
}
