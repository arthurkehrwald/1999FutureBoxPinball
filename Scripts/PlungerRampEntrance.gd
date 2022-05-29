extends StaticBody

onready var col_layer_when_enabled = get_collision_layer()


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")


func on_GameState_changed(new_state, _is_debug_skip):
	if new_state >= GameState.BOSS_APPEARS_STATE and new_state < GameState.VICTORY_STATE:
		set_visible(false)
		set_collision_layer(0)
	elif new_state < GameState.BOSS_APPEARS_STATE:
		set_visible(true)
		set_collision_layer(col_layer_when_enabled)
