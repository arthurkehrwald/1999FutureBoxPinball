extends Label

func _ready():
	if Globals.player_ship != null:
		Globals.player_ship.connect("money_changed", self, "on_PlayerShip_money_changed")
	else:
		push_warning("[PlayerScoreHUD] can't find player. Will not display score.")

func on_PlayerShip_money_changed(new_value, _old_value):
	text = str(new_value)
