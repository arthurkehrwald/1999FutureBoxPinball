extends MeshInstance

var is_out_of_sight = false

onready var ap = get_node("AnimationPlayer")


func _ready():
	# TODO # TODO GameState.connect("state_changed", self, "on_GameState_changed")
	pass


func on_GameState_changed(new_state, _is_debug_skip):
	if new_state < GameState.MISSILES_STATE:
		if is_out_of_sight:
			ap.play_backwards("fly_away")
			is_out_of_sight = false
	else:
		if not is_out_of_sight:
			ap.play("fly_away")
			is_out_of_sight = true
