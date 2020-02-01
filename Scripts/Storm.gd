extends Area

func _enter_tree():
	GameState.connect("pregame_began", self, "set_active", [false])
	GameState.connect("exposition_began", self, "set_active", [true])
	GameState.connect("bossfight_began", self, "set_active", [false])
	
func _ready():
	pass
	
func set_active(is_active):
	set_visible(is_active)
	set_deferred("monitoring", is_active)
	set_deferred("monitorable", is_active)
