extends Control

signal is_active_changed(value)
signal bought_repair (heal_percent)
signal bought_flipper(duration)
signal bought_turret_shot
signal bought_remote_control(duration)

const ITEM_01_TEXTURE = preload("res://HUD/shop_item_01.png")
const ITEM_02_TEXTURE = preload("res://HUD/shop_item_02.png")
const ITEM_03_TEXTURE = preload("res://HUD/shop_item_03.png")
const ITEM_04_TEXTURE = preload("res://HUD/shop_item_04.png")

export var PAUSES_GAME = true
export var PRICE_FOR_EVERYTHING = 200.0
export var DECISION_TIME = 5.0
export var PLAYER_REPAIR_HEAL_PERCENT = 50.0
export var EXTRA_FLIPPER_DURATION = 20.0
export var REMOTE_CONTROL_DURATION = 10.0

var is_active = false
var selected_item = 1

onready var selected_item_rect = get_node("TextureRect")
onready var decision_timer = get_node("DecisionTimer")
onready var time_remaining_label = get_node("TimeRemainingLabel")
onready var time_remaining_bar = get_node("TimeRemainingBar")
onready var audio_player = get_node("AudioStreamPlayer")
onready var glitch_overlay = get_node("../GlitchOverlay")


func _enter_tree():
	Globals.shop_menu = self


func _ready():
	if Globals.player_ship == null:
		push_warning("[ShopMenu] Can't find player! Can't take money away.")
	decision_timer.connect("timeout", self, "on_DecisionTimer_timeout")
	time_remaining_bar.max_value = DECISION_TIME * 100
	set_is_active(false)


func _input(event):
	if not is_active:
		return
	if decision_timer.time_left <= DECISION_TIME - 1 and event.is_action_pressed("ui_accept"):
		decision_timer.stop()
		buy_item(selected_item)
		set_is_active(false)
		emit_signal("closed")
	else:
		var previously_selected = selected_item
		if event.is_action_pressed("ui_left"):
			selected_item -= 1
			if selected_item < 1:
				selected_item = 4
		if event.is_action_pressed("ui_right"):
			selected_item += 1
			if selected_item > 4:
				selected_item = 1
		if previously_selected != selected_item:
			audio_player.play()
			glitch_overlay.super_glitch()
			match selected_item:
				1:
					selected_item_rect.texture = ITEM_01_TEXTURE
				2:
					selected_item_rect.texture = ITEM_02_TEXTURE
				3:
					selected_item_rect.texture = ITEM_03_TEXTURE
				4:
					selected_item_rect.texture = ITEM_04_TEXTURE


func _process(_delta):
	time_remaining_label.text = str(round(decision_timer.time_left))
	time_remaining_bar.value = decision_timer.time_left * 100


func set_is_active(value):
	is_active = value
	emit_signal("is_active_changed", value)
	selected_item = 1
	selected_item_rect.texture = ITEM_01_TEXTURE
	set_visible(value)
	if value:
		Announcer.say("choose_purchase")
		decision_timer.start(DECISION_TIME)
		glitch_overlay.super_glitch()
		set_focus_mode(Control.FOCUS_ALL)
		grab_focus()
	set_process(value)
	if PAUSES_GAME:
		get_tree().paused = value


func on_DecisionTimer_timeout():
	buy_item(selected_item)
	set_is_active(false)


func buy_item(item_index):
	if Globals.player_ship != null:
		Globals.player_ship.set_money(Globals.player_ship.money - PRICE_FOR_EVERYTHING)
	GameState.handle_event(GameState.Event.SHOP_USED)
	match item_index:
		1:
			emit_signal("bought_repair", PLAYER_REPAIR_HEAL_PERCENT)
		2:
			emit_signal("bought_flipper", EXTRA_FLIPPER_DURATION)
		3:
			emit_signal("bought_turret_shot")
		4:
			emit_signal("bought_remote_control", REMOTE_CONTROL_DURATION)
