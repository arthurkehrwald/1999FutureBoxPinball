class_name Shop
extends Area
# Emits singal to activate shop menu if player has
# enough money to buy something, 'shop_enter' input
# is pressed, and at least one pinball is in area.

signal menu_triggered
signal player_bought_turret_shot(ball_to_shoot)

var is_open = false setget set_is_open
var _balls_inside = []


func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")
	GameState.connect("player_money_changed", self, "_on_GameState_player_money_changed")


func _ready():
	set_process(false)


func _process(_delta):
	if Input.is_action_pressed("shop_enter"):
		for ball in _balls_inside:
			ball.set_linear_velocity(Vector3(0, 0, 0))
		set_is_open(false)
		emit_signal("menu_triggered")


func set_is_open(value):
	if value:
		Announcer.say("shop_open", true)
	else:
		set_process(false)
	is_open = value


func _on_Shop_body_entered(body):
	body.on_visibility_changed(false)
	if is_open:
		print("Shop: added ball to array")
		_balls_inside.append(body)
		set_process(true)


func _on_Shop_body_exited(body):
	body.on_visibility_changed(true)
	if _balls_inside.has(body):
		_balls_inside.erase(body)
	if _balls_inside.empty():
		set_process(false) 


func _on_GameState_stage_changed(new_stage, _is_debug_skip):
	if new_stage == GameState.stage.PREGAME:
		set_is_open(false)


func _on_GameState_player_money_changed(new_player_money):
	if not is_open and new_player_money >= Globals.PRICE_FOR_ALL_ITEMS_IN_SHOP:
		set_is_open(true)


func _on_ShopMenu_bought_turret_shot():
	assert(!_balls_inside.empty())
	emit_signal("player_bought_turret_shot", _balls_inside[0])
