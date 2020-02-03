extends Control

signal bought_repair
signal bought_flipper
signal bought_turret_shot
signal bought_remote_control
signal panel_changed
signal closed

export var decision_time = 5.0
export var price_for_all_items = 200

var item_01_texture = preload("res://HUD/shop_item_01.png")
var item_02_texture = preload("res://HUD/shop_item_02.png")
var item_03_texture = preload("res://HUD/shop_item_03.png")
var item_04_texture = preload("res://HUD/shop_item_04.png")

var selected_item = 1

func _ready():
	$DecisionTimer.set_wait_time(decision_time)
	$TimeRemainingBar.max_value = decision_time * 100

func _process(_delta):
	$TimeRemainingLabel.text = str(round($DecisionTimer.time_left))
	$TimeRemainingBar.value = $DecisionTimer.time_left * 100
	if $DecisionTimer.time_left <= decision_time - 1 and Input.is_action_just_pressed("shop_confirm"):
		$DecisionTimer.stop()
		buy_item(selected_item)
		set_active(false)
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
			emit_signal("panel_changed")
			match selected_item:
				1:
					$TextureRect.texture = item_01_texture
				2:
					$TextureRect.texture = item_02_texture
				3:
					$TextureRect.texture = item_03_texture
				4:
					$TextureRect.texture = item_04_texture	

func set_active(is_active):
	#print("ShopMenu: active - ", is_active)
	selected_item = 1
	$TextureRect.texture = item_01_texture
	set_visible(is_active)
	if is_active:
		$DecisionTimer.start()
	set_process(is_active)
	GameState.set_paused(is_active)

func _on_DecisionTimer_timeout():
	#print("ShopMenu: decision timer timeout")
	buy_item(selected_item)
	emit_signal("closed")
	set_active(false)

func buy_item(item_index):
	#print("ShopMenu: player bought a thing")
	GameState.set_player_money(GameState.player_money - price_for_all_items)
	GameState.on_ShopMenu_player_bought_anything()
	match item_index:
		1:
			emit_signal("bought_repair")
		2:
			emit_signal("bought_flipper")
		3:
			emit_signal("bought_turret_shot")
		4:
			emit_signal("bought_remote_control")
