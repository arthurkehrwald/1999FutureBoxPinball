extends TextureRect

export(Texture) var green_tex
export(Texture) var red_tex

func _ready():
	if Globals.player_ship != null:
		Globals.player_ship.connect("health_changed", self, "on_PlayerShip_health_changed")
	else:
		push_warning("[PlayerStatsHUD] can't find player. Will not change color.")

func on_PlayerShip_health_changed(new_health, old_health, max_health):
	var is_hp_critical = new_health / max_health * 100 <= Globals.PLAYER_CRITICAL_HEALTH_PERCENT
	var ui_color = Globals.RED_COLOR if is_hp_critical else Globals.CYAN_COLOR
	texture = red_tex if is_hp_critical else green_tex
