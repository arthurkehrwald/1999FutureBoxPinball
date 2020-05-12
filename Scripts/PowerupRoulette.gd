extends Control

signal selected_repair(heal_percent)
signal selected_stopper(duration)
signal selected_turret
signal selected_remote
signal selected_boost
signal remote_expired
signal turret_expired

enum {
	INACTIVE,
	SPINNING,
	SELECTING,
	INSTRUCTING
}
enum Powerup {
	REPAIR,
	STOPPER,
	TURRET,
	REMOTE,
	BOOST
}

const ICON_IMGS = {
	Powerup.REPAIR: preload("res://HUD/repair_icon.png"),
	Powerup.STOPPER: preload("res://HUD/stopper_icon.png"),
	Powerup.TURRET: preload("res://HUD/turret_icon.png"),
	Powerup.REMOTE: preload("res://HUD/remote_icon.png"),
	Powerup.BOOST: preload("res://HUD/boost_icon.png")
}
const INSTRUCTION_IMGS = {
	Powerup.REPAIR: null,
	Powerup.STOPPER: null,
	Powerup.TURRET: preload("res://HUD/turret_instructions.png"),
	Powerup.REMOTE: preload("res://HUD/remote_instructions.png"),
	Powerup.BOOST: preload("res://HUD/boost_instructions.png")
}
const POWERUP_STR_TO_ENUM = {
	"Repair": Powerup.REPAIR,
	"Stopper": Powerup.STOPPER,
	"Turret": Powerup.TURRET,
	"Remote": Powerup.REMOTE,
	"Boost": Powerup.BOOST
}
const POWERUP_ENUM_TO_STR = {
	Powerup.REPAIR: "Repair",
	Powerup.STOPPER: "Stopper",
	Powerup.TURRET: "Turret",
	Powerup.REMOTE: "Remote",
	Powerup.BOOST: "Boost"
}
const POWERUP_ODDS_STR = {
	"Stopper": 1.0,
	"Turret": 1.0,
	"Remote": 1.0,
	"Boost": 1.0
}
const ICONS_VISIBLE_AT_A_TIME = 4

export var PLAYER_REPAIR_HEAL_PERCENT = 50.0
export var POWERUP_ODDS_PER_STAGE = {
	"0-Testing": POWERUP_ODDS_STR,
	"1-Pregame": POWERUP_ODDS_STR,
	"2-Exposition": POWERUP_ODDS_STR,
	"3-EnemyFleet": POWERUP_ODDS_STR,
	"4-BossAppears": POWERUP_ODDS_STR,
	"5-Missiles": POWERUP_ODDS_STR,
	"6-Trex": POWERUP_ODDS_STR,
	"7-BlackHole": POWERUP_ODDS_STR,
	"8-Eclipse": POWERUP_ODDS_STR,
	"9-Victory": POWERUP_ODDS_STR,
	"10-Defeat": POWERUP_ODDS_STR
}
export var POWERUP_DURATIONS = {
	"Repair": 5.0,
	"Stopper": 30.0,
	"Turret": 10.0,
	"Remote": 30.0,
	"Boost": 30.0
}

var spin_speed = 0
var spin_speed_decay = 0
var state = INACTIVE
var powerup_of_icon = {}
var powerup_odds_per_state = {}
var powerup_timers = {}
var timer_on_time_bar = null

onready var icons = get_node("Icons")
onready var move_range = icons.get_child(0).rect_size.x * ICONS_VISIBLE_AT_A_TIME
onready var half_icon_width = icons.get_child(0).rect_size.x * .5
onready var max_progress = 1.0 / ICONS_VISIBLE_AT_A_TIME * icons.get_child_count()
onready var tween = get_node("Tween")
onready var glitch_overlay = get_node("../GlitchOverlay")
onready var instruction_rect = get_node("InstructionRect")
onready var first_icon = icons.get_child(0)
onready var name_label = get_node("NameLabel")
onready var time_bar = get_node("TimeBar")
onready var selected_icon_rect = get_node("SelectedIconRect")


func _enter_tree():
	Globals.powerup_roulette = self


func _ready():
	for stage_str_key in POWERUP_ODDS_PER_STAGE.keys():
		var powerup_odds = {}
		for powerup_str_key in POWERUP_ODDS_PER_STAGE[stage_str_key].keys():
			var powerup = POWERUP_STR_TO_ENUM[powerup_str_key]
			powerup_odds[powerup] = POWERUP_ODDS_PER_STAGE[stage_str_key][powerup_str_key]
		var game_state = GameState.NAME_STATE_DICT[stage_str_key]
		powerup_odds_per_state[game_state] = powerup_odds
	visible = false
	randomize()
	if Globals.player_ship == null:
		print("[Powerup Roulette] can't find player ship. Repair powerup unavailable.")
	for powerup_str in POWERUP_DURATIONS:
		var powerup_type = POWERUP_STR_TO_ENUM[powerup_str]
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = POWERUP_DURATIONS[powerup_str]
		if powerup_type == Powerup.TURRET and Globals.player_turret != null:
			timer.wait_time *= Globals.player_turret.TIME_SCALE_WHEN_AIMING
		powerup_timers[powerup_type] = timer
		timer.connect("timeout", self, "on_PowerupTimer_timeout", [powerup_type])
		add_child(timer)


func _process(delta):
	if state == SPINNING:
		if spin_speed > 0:
			spin(delta)
			spin_speed -= spin_speed_decay * delta
		else:
			state = SELECTING
			var selected_icon = get_center_icon()
			var selected_powerup = powerup_of_icon[selected_icon]
			trigger_selection_animation(selected_icon)
			var ap = selected_icon.get_node("AnimationPlayer")
			ap.connect("animation_finished", self, "on_SelectionAnim_finished", [selected_powerup], CONNECT_ONESHOT)
	elif state == INSTRUCTING:
		time_bar.value = timer_on_time_bar.time_left * 100


func on_SelectionAnim_finished(_anim_name, selected_powerup):
	activate_powerup(selected_powerup)
	display_instructions(selected_powerup)


func spin(delta):
	for icon in icons.get_children():
		var progress = (icon.rect_position.x + half_icon_width) / move_range
		if progress >= max_progress:
			icon.rect_position.x = -half_icon_width
			if icon == first_icon:
				even_icon_spacing()
		icon.rect_position.x += spin_speed * move_range * delta
		var scale = -2 * pow(progress - .5, 2) + 1
		icon.rect_scale = Vector2.ONE * scale
		if progress < .2:
			icon.modulate = Color(1, 1, 1, progress * 5)
		elif progress > .8:
			icon.modulate = Color(1, 1 , 1, (1 - progress) * 5)


func get_center_icon():
	var selected_icon = null
	var min_offset_from_center = move_range
	for icon in icons.get_children():
		var offset = icon.rect_position.x + half_icon_width
		var offset_from_center = abs((.5 * move_range) - offset)
		if offset_from_center < min_offset_from_center:
			min_offset_from_center = offset_from_center
			selected_icon = icon
	return selected_icon


func trigger_selection_animation(selected_icon):
	for icon in icons.get_children():
		if icon == selected_icon:
			tween.interpolate_property(icon, "rect_position",
					icon.rect_position, Vector2(move_range * .5 - half_icon_width, 0),
					 .5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			icon.get_node("AnimationPlayer").play("powerup_icon_scale_up")
		else:
			tween.interpolate_property(icon, "modulate",
					icon.modulate, Color(1, 1, 1, 0),
					 .5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.interpolate_property(icon, "rect_scale",
					icon.rect_scale, Vector2.ZERO,
					 .5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func activate_powerup(powerup):
	match powerup:
		Powerup.REPAIR:
			emit_signal("selected_repair", PLAYER_REPAIR_HEAL_PERCENT)
		Powerup.STOPPER: 
			emit_signal("selected_stopper")
		Powerup.TURRET:
			emit_signal("selected_turret")
		Powerup.REMOTE:
			emit_signal("selected_remote")
		Powerup.BOOST: 
			emit_signal("selected_boost")
	GameState.handle_event(GameState.Event.SHOP_USED)


func calc_odds():
	var sum_of_non_repair_odds = 0
	for key in powerup_odds_per_state[GameState.current_state]:
		var chance = powerup_odds_per_state[GameState.current_state][key]
		if chance > 0:
			sum_of_non_repair_odds += chance
	var repair_chance = 0
	if sum_of_non_repair_odds == 0:
		repair_chance = 1
	elif Globals.player_ship != null:
		repair_chance = 1 - Globals.player_ship.health / Globals.player_ship.MAX_HEALTH
	var current_powerup_odds = {Powerup.REPAIR: repair_chance}
	if sum_of_non_repair_odds > 0:
		for key in powerup_odds_per_state[GameState.current_state]:
			var chance = powerup_odds_per_state[GameState.current_state][key]
			current_powerup_odds[key] = chance / sum_of_non_repair_odds * (1 - repair_chance)
	return current_powerup_odds


func start_spinning(speed, decay):
	spin_speed = speed
	spin_speed_decay = decay
	if state == SPINNING:
		return
	state = SPINNING
	var powerup_odds = calc_odds()
	var i = 0
	for icon in icons.get_children():
		icon.rect_scale = Vector2.ONE
		icon.modulate = Color(1, 1, 1, 1)
		icon.rect_position.x = icon.rect_size.x * i
		icon.get_node("AnimationPlayer").stop() 
		var r = randf()
		var s = 0
		for key in powerup_odds:
			if powerup_odds[key] + s > r:
				icon.texture = ICON_IMGS[key]
				powerup_of_icon[icon] = key
				break
			else:
				s += powerup_odds[key]
		i += 1
	visible = true
	icons.visible = true
	instruction_rect.visible = false
	name_label.visible = false
	time_bar.visible = false
	selected_icon_rect.visible = false


# Without calling this regularly, rounding error would lead to uneven distances
# between icons when spinning fast.
func even_icon_spacing():
	var i = 0
	for icon in icons.get_children():
		icon.rect_position.x = -half_icon_width + icon.rect_size.x * i
		i += 1


func display_instructions(powerup):
	state = INSTRUCTING
	
	selected_icon_rect.texture = ICON_IMGS[powerup]
	name_label.text = POWERUP_ENUM_TO_STR[powerup]
	instruction_rect.texture = INSTRUCTION_IMGS[powerup]
	if powerup_timers[powerup].time_left == 0 or timer_on_time_bar == powerup_timers[powerup]:
		powerup_timers[powerup].start()
	timer_on_time_bar = powerup_timers[powerup]
	tween.start()
	time_bar.max_value = timer_on_time_bar.wait_time * 100
	
	icons.visible = false
	name_label.visible = true
	selected_icon_rect.visible = true
	instruction_rect.visible = true
	time_bar.visible = true
	
	if glitch_overlay != null:
		glitch_overlay.super_glitch()


func on_PowerupTimer_timeout(expired_powerup):
	if expired_powerup == Powerup.REMOTE:
		emit_signal("remote_expired")
	elif expired_powerup == Powerup.TURRET:
		emit_signal("turret_expired")
	var active_powerup_with_least_time_left = 0
	var least_time_left = 0
	for key in powerup_timers:
		if powerup_timers[key].time_left > 0:
			if least_time_left == 0 or powerup_timers[key].time_left < least_time_left:
				least_time_left = powerup_timers[key].time_left
				active_powerup_with_least_time_left = key
	if least_time_left > 0:
		display_instructions(active_powerup_with_least_time_left)
	elif state == INSTRUCTING:
		state = INACTIVE
		visible = false
