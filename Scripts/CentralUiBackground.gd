class_name CentralUiBackground
extends TextureRect

export var red_bg: Texture
onready var normal_bg := texture

func _ready():
	if Globals.player_ship == null:
		push_warning("[CentralHUDBackground] can't find player ship. Will not" 
				+ "become red when player health critical.")
	else:
		Globals.player_ship.connect("health_changed", self, "on_PlayerShip_health_changed")


func on_PlayerShip_health_changed(new_health, _old_health, max_health):
	if new_health / max_health * 100 <= Globals.PLAYER_CRITICAL_HEALTH_PERCENT:
		texture = red_bg
	else:
		texture = normal_bg
