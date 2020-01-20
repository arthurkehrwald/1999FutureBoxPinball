extends "res://Scripts/BallBombCommon.gd"

export var fuse_time = 5
export var chain_explosions_enabled = true
export var chain_explosion_delay = .2

const explosion_hitreg_duration = .1

var is_exploding = false

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
