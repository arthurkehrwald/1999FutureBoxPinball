extends Control

signal is_active_changed(value)
signal selected_repair(heal_percent)
signal selected_turret(pinball_in_shop)
signal selected_stopper(duration)
signal selected_boost
signal selected_remote_on_deleted_ball
signal selected_turret_on_deleted_ball

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
export var STOPPER_DURATION = 30.0
export var TURRET_TIME_TO_SHOOT = 10.0
export var REMOTE_DURATION = 30.0
export var BOOST_DURATION = 30.0
export var SPIN_SPEED_FACTOR = .3
export var SPEED_DECAY = .5
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

var speed = 700
var pinball_in_shop = null
var is_active = false
var powerup_of_icon = {}
var powerup_odds_per_state = {}
var powerup_timers = {}
var timer_on_time_bar = null

onready var icons = get_node("Icons")
onready var move_range = icons.get_child(0).rect_size.x * ICONS_VISIBLE_AT_A_TIME
onready var icon_width = icons.get_child(0).rect_size.x * .5
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
	set_process(false)
	set_visible(false)
	randomize()
	if Globals.player_ship == null:
		print("[Powerup Roulette] can't find player ship. Repair powerup unavailable.")
	for powerup_type in POWERUP_DURATIONS:
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = POWERUP_DURATIONS[powerup_type]
		powerup_timers[POWERUP_STR_TO_ENUM[powerup_type]] = timer
		timer.connect("timeout", self, "on_PowerupTimer_timeout")
		add_child(timer)


func _process(delta):
	if speed > 0:
		spin(delta)
		speed -= SPEED_DECAY * delta
	else:
		var selected_icon = get_center_icon()
		trigger_selection_animation(selected_icon)
		var selected_powerup = powerup_of_icon[selected_icon]
		match selected_powerup:
			Powerup.REPAIR:
				emit_signal("selected_repair", PLAYER_REPAIR_HEAL_PERCENT)
				print("rolled repair")
			Powerup.STOPPER: 
				emit_signal("selected_stopper")
				print("rolled stopper")
			Powerup.TURRET:
				if pinball_in_shop != null and pinball_in_shop.get_ref():
					emit_signal("selected_turret", pinball_in_shop.get_ref())
				else:
					emit_signal("selected_turret_on_deleted_ball")
				print("rolled turret")
			Powerup.REMOTE:
				if pinball_in_shop != null and pinball_in_shop.get_ref():
					pinball_in_shop.get_ref().set_is_remote_controlled(true)
				else:
					emit_signal("selected_remote_on_deleted_ball")
				print("rolled remote")
			Powerup.BOOST: 
				emit_signal("selected_boost")
				print("rolled boost")
		GameState.handle_event(GameState.Event.SHOP_USED)
		if glitch_overlay != null:
			glitch_overlay.super_glitch()
		display_powerup_screen(selected_powerup)
		set_process(false)


func spin(delta):
	for icon in icons.get_children():
		var progress = (icon.rect_position.x + icon_width) / move_range
		if progress >= max_progress:
			icon.rect_position.x = -icon_width
			if icon == first_icon:
				even_icon_spacing()
		icon.rect_position.x += speed * move_range * delta
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
		var offset = icon.rect_position.x + icon_width
		var offset_from_center = abs((.5 * move_range) - offset)
		if offset_from_center < min_offset_from_center:
			min_offset_from_center = offset_from_center
			selected_icon = icon
	return selected_icon


func trigger_selection_animation(selected_icon):
	for icon in icons.get_children():
		if icon == selected_icon:
			tween.interpolate_property(icon, "rect_position",
					icon.rect_position, Vector2(move_range * .5 - icon_width, 0),
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


func set_is_active(value, _pinball_in_shop = null):
	if is_active == value:
		return
	if _pinball_in_shop != null:
		pinball_in_shop = weakref(_pinball_in_shop)
	else:
		pinball_in_shop = null
	if value:
		if pinball_in_shop != null and pinball_in_shop.get_ref():
			speed = pinball_in_shop.get_ref().get_linear_velocity().length() * SPIN_SPEED_FACTOR
			print(speed)
		else:
			return
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
		print("repair chance :", repair_chance)
		var current_powerup_odds = {Powerup.REPAIR: repair_chance}
		if sum_of_non_repair_odds > 0:
			for key in powerup_odds_per_state[GameState.current_state]:
				var chance = powerup_odds_per_state[GameState.current_state][key]
				current_powerup_odds[key] = chance / sum_of_non_repair_odds * (1 - repair_chance)
				print("powerup ", key, " chance: ", current_powerup_odds[key])
		var i = 0
		for icon in icons.get_children():
			icon.rect_scale = Vector2.ONE
			icon.modulate = Color(1, 1, 1, 1)
			icon.rect_position.x = icon.rect_size.x * i
			var r = randf()
			var s = 0
			for key in current_powerup_odds:
				if current_powerup_odds[key] + s > r:
					icon.texture = ICON_IMGS[key]
					powerup_of_icon[icon] = key
					break
				else:
					s += current_powerup_odds[key]
			i += 1
	if glitch_overlay != null:
		glitch_overlay.super_glitch()
	set_visible(value)
	set_process(value)
	instruction_rect.set_visible(false)
	name_label.set_visible(false)
	time_bar.set_visible(false)
	selected_icon_rect.set_visible(false)
	is_active = value
	emit_signal("is_active_changed", value)


# Without calling this regularly, rounding error would lead to uneven distances
# between icons when spinning fast.
func even_icon_spacing():
	var i = 0
	for icon in icons.get_children():
		icon.rect_position.x = -icon_width + icon.rect_size.x * i
		i += 1


func display_powerup_screen(type):
	selected_icon_rect.texture = ICON_IMGS[type]
	selected_icon_rect.set_visible(true)
	name_label.text = POWERUP_ENUM_TO_STR[type]
	name_label.set_visible(true)
	instruction_rect.texture = INSTRUCTION_IMGS[type]
	instruction_rect.set_visible(true)
	if powerup_timers[type].time_left == 0:
		powerup_timers[type].start()
	timer_on_time_bar = powerup_timers[type]
	tween.start()
	time_bar.set_visible(true)


func on_PowerupTimer_timeout():
	var active_powerup_with_least_time_left = 0
	var least_time_left = 0
	for key in powerup_timers:
		if powerup_timers[key].time_left > 0:
			if least_time_left == 0 or powerup_timers[key].time_left < least_time_left:
				least_time_left = powerup_timers[key].time_left
				active_powerup_with_least_time_left = key
	if least_time_left > 0:
		display_powerup_screen(active_powerup_with_least_time_left)
	else:
		set_is_active(false)
