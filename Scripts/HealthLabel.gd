extends Label

func _ready():
	if Globals.player_ship != null:
		Globals.player_ship.connect("health_changed", self, "on_PlayerShip_health_changed")
	else:
		push_warning("[PlayerScoreHUD] can't find player. Will not display stats.")

func on_PlayerShip_health_changed(new_health, old_health, max_health):
	text = str(round(new_health / max_health * 100)) + "%"
