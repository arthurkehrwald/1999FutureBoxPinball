extends Area

func set_is_active(is_active):
	set_visible(is_active)
	set_deferred("monitoring", is_active)
	set_deferred("monitorable", is_active)
