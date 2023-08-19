class_name WarningUi
extends "res://Scripts/StackedUi.gd"

var is_player_hp_critical = false

func _enter_tree():
	Globals.warning_hud = self

func _ready():
	if Globals.player_ship == null:
		push_warning("[WarningHUD] can't find player ship. Will not" 
				+ " become show warning when player health critical.")
	else:
		Globals.player_ship.connect("health_changed", self, "on_PlayerShip_health_changed")

func on_PlayerShip_health_changed(new_health, _old_health, max_health):
	is_player_hp_critical = new_health / max_health * 100 <= Globals.PLAYER_CRITICAL_HEALTH_PERCENT
	set_wants_focus(is_player_hp_critical)
