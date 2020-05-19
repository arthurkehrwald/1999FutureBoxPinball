extends TextureRect

const GREEN_BG = preload("res://HUD/central_hud_background.png")
const RED_BG = preload("res://HUD/central_hud_background_red.png")


func _ready():
	if Globals.player_ship == null:
		push_warning("[CentralHUDBackground] can't find player ship. Will not" 
				+ "become red when player health critical.")
	else:
		Globals.player_ship.connect("health_changed", self, "on_PlayerShip_health_changed")


func on_PlayerShip_health_changed(new_health, _old_health, max_health):
	if new_health / max_health * 100 <= Globals.PLAYER_CRITICAL_HEALTH_PERCENT:
		texture = RED_BG
	else:
		texture = GREEN_BG
