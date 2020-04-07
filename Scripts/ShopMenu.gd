extends Control

signal bought_repair(heal_percent)
signal bought_flipper
signal bought_turret_shot
signal bought_remote_control
signal panel_changed
signal closed

export var DECISION_TIME = 5.0
export var REPAIR_HEAL_PERCENT = 50.0

var item_01_texture = preload("res://HUD/shop_item_01.png")
var item_02_texture = preload("res://HUD/shop_item_02.png")
var item_03_texture = preload("res://HUD/shop_item_03.png")
var item_04_texture = preload("res://HUD/shop_item_04.png")

var selected_item = 1

onready var _selected_item_rect = get_node("TextureRect")
onready var _decision_timer = get_node("DecisionTimer")
onready var _time_remaining_label = get_node("TimeRemainingLabel")
onready var _time_remaining_bar = get_node("TimeRemainingBar")
onready var _audio_player = get_node("AudioStreamPlayer")


func _enter_tree():
	Globals.shop_menu = self


func _ready():
	_decision_timer.set_wait_time(DECISION_TIME)
	_time_remaining_bar.max_value = DECISION_TIME * 100


func _process(_delta):
	_time_remaining_label.text = str(round(_decision_timer.time_left))
	_time_remaining_bar.value = _decision_timer.time_left * 100
	if _decision_timer.time_left <= DECISION_TIME - 1 and Input.is_action_just_pressed("shop_confirm"):
		_decision_timer.stop()
		buy_item(selected_item)
		set_is_active(false)
		emit_signal("closed")
	else:
		var previously_selected = selected_item
		if Input.is_action_just_pressed("flipper_left"):
			selected_item -= 1
			if selected_item < 1:
				selected_item = 4
		if Input.is_action_just_pressed("flipper_right"):
			selected_item += 1
			if selected_item > 4:
				selected_item = 1
				
		if previously_selected != selected_item:
			_audio_player.play()
			emit_signal("panel_changed")
			match selected_item:
				1:
					_selected_item_rect.texture = item_01_texture
				2:
					_selected_item_rect.texture = item_02_texture
				3:
					_selected_item_rect.texture = item_03_texture
				4:
					_selected_item_rect.texture = item_04_texture	


func set_is_active(is_active):
	#print("ShopMenu: active - ", is_active)
	selected_item = 1
	_selected_item_rect.texture = item_01_texture
	set_visible(is_active)
	if is_active:
		Announcer.say("choose_purchase")
		_decision_timer.start()
	set_process(is_active)
	get_tree().paused = is_active

func _on_DecisionTimer_timeout():
	#print("ShopMenu: decision timer timeout")
	buy_item(selected_item)
	emit_signal("closed")
	set_is_active(false)


func buy_item(item_index):
	#print("ShopMenu: player bought a thing")
	#GameState.set_player_money(GameState.player_money - PRICE_FOR_ALL_ITEMS)
	GameState.add_player_money(-Globals.PRICE_FOR_ALL_ITEMS_IN_SHOP)
	GameState.handle_event(GameState.Event.SHOP_USED)
	match item_index:
		1:
			emit_signal("bought_repair", REPAIR_HEAL_PERCENT)
		2:
			emit_signal("bought_flipper")
		3:
			emit_signal("bought_turret_shot")
		4:
			emit_signal("bought_remote_control")
