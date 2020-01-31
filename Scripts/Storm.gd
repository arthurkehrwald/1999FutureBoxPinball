extends Area

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	GameState.connect("storm_set_active", self, "set_active")
	
func _ready():
	pass

func _on_GameState_global_reset(_is_init):
	set_active(false)
	
func set_active(is_active):
	set_visible(is_active)
	set_deferred("monitoring", is_active)
	set_deferred("monitorable", is_active)
