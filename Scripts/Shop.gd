class_name Shop
extends Area
# Emits singal to activate shop menu if player has
# enough money to buy something, 'shop_enter' input
# is pressed, and at least one pinball is in area.

signal menu_triggered
signal player_bought_turret_shot(ball_to_shoot)

export(NodePath) var PATH_TO_SHOP_MENU = "../ShopMenu"
export var PRICE_FOR_ALL_ITEMS = 200.0

var is_open = false setget set_is_open
var balls_inside = []

onready var shop_menu = get_node_or_null(PATH_TO_SHOP_MENU)


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")
	GameState.connect("player_money_changed", self, "on_GameState_player_money_changed")
	connect("body_entered", self, "on_Shop_body_entered")
	connect("body_exited", self, "on_Shop_body_exited")
	if shop_menu == null:
		push_warning("Shop: Can't find shop menu! If it is in the scene, make it"
				+ " a sibling of shop or adjust the path to it in the export vars"
				+ " of the shop in the inspector.")
	set_process(false)


func _process(_delta):
	if Input.is_action_pressed("shop_enter"):
		for ball in balls_inside:
			ball.set_linear_velocity(Vector3(0, 0, 0))
		shop_menu.set_is_active(true)
		set_is_open(false)


func set_is_open(value):
	if value:
		Announcer.say("shop_open", true)
	else:
		set_process(false)
	is_open = value


func on_Shop_body_entered(body):
	if !body.is_in_group("pinballs"):
		return
	body.on_visibility_changed(false)
	if is_open:
		print("Shop: added ball to array")
		balls_inside.push_back(body)
		set_process(true)


func on_Shop_body_exited(body):
	body.on_visibility_changed(true)
	if balls_inside.has(body):
		balls_inside.erase(body)
	if balls_inside.empty():
		set_process(false) 


func on_GameState_changed(new_stage, _is_debug_skip):
	if new_stage == GameState.PREGAME:
		set_is_open(false)


func on_Player_money_changed(new_player_money):
	if not is_open and new_player_money >= Globals.PRICE_FOR_ALL_ITEMS_IN_SHOP:
		set_is_open(true)


func on_ShopMenu_bought_turret_shot():
	assert(!balls_inside.empty())
	emit_signal("player_bought_turret_shot", balls_inside[0])


func on_ShopMenu_bought_remote_control():
	assert(not balls_inside.empty())
	balls_inside[0].set_is_remote_controlled(true)
