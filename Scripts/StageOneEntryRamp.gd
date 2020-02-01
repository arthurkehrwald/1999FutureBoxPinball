extends "res://Scripts/PseudoPhysicsPathFollow.gd"

func _enter_tree():
	GameState.connect("exposition_began", self, "reset", [true])
	GameState.connect("bossfight_began", self, "reset", [false])
