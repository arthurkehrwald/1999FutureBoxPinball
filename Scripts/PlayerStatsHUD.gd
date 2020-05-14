extends Control

const MONEY_LABEL_FORMAT_STRING = "%s,000"

onready var glitch_overlay = get_node("../GlitchOverlay")
onready var shop_meter = get_node("Background/ShopMeter")
onready var health_bar = get_node("Background/HealthBar")
onready var money_label = get_node("Background/ScoreLabel")
onready var health_label = get_node("Background/HealthLabel")


func _ready():
	if Globals.player_ship != null:
		Globals.player_ship.connect("health_changed", self, "on_PlayerShip_health_changed")
		Globals.player_ship.connect("money_changed", self, "on_PlayerShip_money_changed")
	else:
		push_warning("[PlayerStatsHUD] can't find player. Will not display stats.")
	if Globals.moon_shop != null:
		Globals.moon_shop.connect("unlock_progress_changed", shop_meter, "set_value")
	else:
		push_warning("[PlayerStatsHUD] can't find moon shop. Will not display progress to opening.")


func on_PlayerShip_money_changed(new_value, _old_value):
	money_label.text = "%07d" % new_value
	money_label.text = money_label.text.insert(1, ",")
	money_label.text = money_label.text.insert(5, ",")
	#glitch_overlay.super_glitch()


func on_PlayerShip_health_changed(new_health, old_health, max_health):
	health_bar.max_value = max_health
	health_bar.value = new_health
	health_label.text = str(round(new_health / max_health * 100)) + "%"
	if new_health < old_health:
		glitch_overlay.super_glitch()
