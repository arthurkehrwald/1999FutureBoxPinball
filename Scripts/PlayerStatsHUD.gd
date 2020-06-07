extends Control

const GREEN_PANEL = preload("res://HUD/panel_right.png")
const RED_PANEL = preload("res://HUD/panel_right_red.png")

onready var glitch_overlay = get_node("../GlitchOverlay")
onready var shop_meter = get_node("Background/ShopMeter")
onready var health_bar = get_node("Background/HealthBar")
onready var score_label = get_node("Background/ScoreLabel")
onready var health_label = get_node("Background/HealthLabel")
onready var background_rect = get_node("Background")
onready var score_name_label = get_node("Background/ScoreNameLabel")
onready var health_name_label = get_node("Background/HealthNameLabel")
onready var shop_name_label = get_node("Background/ShopNameLabel")
onready var car_fill = get_node("Background/CarFill")
onready var anim_player = get_node("AnimationPlayer")


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
	score_label.text = "%07d" % new_value
	score_label.text = score_label.text.insert(1, ",")
	score_label.text = score_label.text.insert(5, ",")
	#glitch_overlay.super_glitch()


func on_PlayerShip_health_changed(new_health, old_health, max_health):
	var is_hp_critical = new_health / max_health * 100 <= Globals.PLAYER_CRITICAL_HEALTH_PERCENT
	var ui_color = Globals.RED_COLOR if is_hp_critical else Globals.CYAN_COLOR
	background_rect.texture = RED_PANEL if is_hp_critical else GREEN_PANEL
	score_label.set("custom_colors/font_color", ui_color)
	score_name_label.set("custom_colors/font_color", ui_color)
	health_label.set("custom_colors/font_color", ui_color)
	health_name_label.set("custom_colors/font_color", ui_color)
	shop_name_label.set("custom_colors/font_color", ui_color)
	shop_meter.tint_over = ui_color
	shop_meter.tint_progress = ui_color
	car_fill.visible = is_hp_critical
	if is_hp_critical and not anim_player.is_playing():
		anim_player.play("car_flash")
	elif not is_hp_critical and anim_player.is_playing():
		anim_player.stop()
	
	health_bar.max_value = max_health
	health_bar.value = new_health
	health_label.text = str(round(new_health / max_health * 100)) + "%"
	if new_health < old_health:
		glitch_overlay.super_glitch()
