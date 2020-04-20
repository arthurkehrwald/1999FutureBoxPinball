extends Control

const MONEY_LABEL_FORMAT_STRING = "%s,000,000,000"
const PLAYER_HEALTH_LABEL_FORMAT_STRING = "%s%"

onready var glitch_overlay = get_node("../GlitchOverlay")
onready var coolness_meter = get_node("Background/CoolnessMeter")
onready var health_bar = get_node("Background/HealthBar")
onready var money_desc_label = get_node("Background/MoneyDescLabel")
onready var money_label = get_node("Background/MoneyLabel")
onready var health_label = get_node("Background/HealthLabel")


func _ready():
	if Globals.player_ship != null:
		Globals.player_ship.connect("health_changed", self, "on_PlayerShip_health_changed")
		Globals.player_ship.connect("money_changed", self, "on_PlayerShip_money_changed")
		Globals.player_ship.connect("coolness_changed", self, "on_PlayerShip_coolness_changed")
	else:
		push_warning("[PlayerStatsHUD] can't find player. Will not display stats.")
	if Globals.shop_menu == null:
		push_warning("[PlayerStatsHUD] can't find shop menu. Will not display when the shop is open.")


func on_PlayerShip_money_changed(new_value, _old_value):
	new_value = clamp(new_value, 0, 999)
	money_label.text = MONEY_LABEL_FORMAT_STRING % int(new_value)
	if new_value == 0:
		money_desc_label.text = "YOU'RE BROKE"
	elif new_value == 999:
		money_desc_label.text = "CAP"
	elif Globals.shop_menu != null and new_value >= Globals.shop_menu.PRICE_FOR_EVERYTHING:
		money_desc_label.text = "SHOP OPEN"
	else:
			money_desc_label.text = ""
	glitch_overlay.super_glitch()


func on_PlayerShip_coolness_changed(new_value, old_value):
	coolness_meter.value = new_value
	if new_value > old_value:
		glitch_overlay.super_glitch()


func on_PlayerShip_health_changed(new_health, _old_health, max_health):
	health_bar.max_value = max_health
	health_bar.value = new_health
	health_label.text = str(round(new_health / max_health * 100)) + "%"
	glitch_overlay.super_glitch()
