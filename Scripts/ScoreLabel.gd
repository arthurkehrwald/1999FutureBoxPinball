extends Label

func _ready():
	if Globals.player_ship != null:
		Globals.player_ship.connect("money_changed", self, "on_PlayerShip_money_changed")
		Globals.player_ship.connect("health_changed", self, "on_PlayerShip_health_changed")
	else:
		push_warning("[PlayerScoreHUD] can't find player. Will not display stats.")

func on_PlayerShip_money_changed(new_value, _old_value):
	text = str(new_value)

func on_PlayerShip_health_changed(new_health, old_health, max_health):
	var is_hp_critical = new_health / max_health * 100 <= Globals.PLAYER_CRITICAL_HEALTH_PERCENT
	var ui_color = Globals.RED_COLOR if is_hp_critical else Globals.CYAN_COLOR
	set("custom_colors/font_color", ui_color)
