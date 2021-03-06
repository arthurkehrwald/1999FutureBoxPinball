class_name ShopEntranceV2
extends Area
# Emits singal to activate shop menu if player has
# enough money to buy something, 'shop_enter' input
# is pressed, and at least one pinball is in area.

export var PRICE_FOR_EVERYTHING = 200.0

var is_open = false setget set_is_open


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")
	if Globals.player_ship != null:
		Globals.player_ship.connect("money_changed", self, "on_Player_money_changed")
	else:
		push_warning("[ShopEntrance] Can't find player ship! Won't be able to open"
				+ " because player's money is unknown.")
	if Globals.powerup_roulette == null:
		push_warning("[ShopEntrance] Can't find powerup roulette! Will not activate it.")
	connect("body_entered", self, "on_Shop_body_entered")
	connect("body_exited", self, "on_Shop_body_exited")


func set_is_open(value):
	if value:
		Announcer.say("shop_open", true)
	else:
		set_process(false)
	is_open = value


func on_Shop_body_entered(body):
	if body.is_in_group("pinballs"):
		body.on_visibility_changed(false)
		if is_open and Globals.powerup_roulette != null:
			Globals.powerup_roulette.set_is_active(true, body)
			set_is_open(false)
			if Globals.player_ship != null:
				Globals.player_ship.set_money(Globals.player_ship.money - PRICE_FOR_EVERYTHING)


func on_Shop_body_exited(body):
	if body.is_in_group("pinballs"):
		body.on_visibility_changed(true)


func on_GameState_changed(new_stage, _is_debug_skip):
	if new_stage == GameState.PREGAME:
		set_is_open(false)


func on_Player_money_changed(new_value, _old_value):
	if not is_open and new_value >= PRICE_FOR_EVERYTHING:
		set_is_open(true)


#func on_ShopMenu_bought_turret_shot():
#	assert(!balls_inside.empty())
#	emit_signal("bought_turret_shot", balls_inside[0])
#
#
#func on_ShopMenu_bought_remote_control(duration):
#	if not balls_inside.empty():
#		balls_inside[0].set_is_remote_controlled(true, duration)
