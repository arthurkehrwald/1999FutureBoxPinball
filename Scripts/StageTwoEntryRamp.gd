extends "res://Scripts/PseudoPhysicsPathFollow.gd"

func _enter_tree():
	GameState.connect("bossfight_began", self, "reset", [true])
