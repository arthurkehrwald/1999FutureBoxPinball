class_name PlayerShip
extends "res://Scripts/Damageable.gd"

signal money_changed(new_value, old_value)
signal coolness_changed(new_value, old_value)

export var COOLNESS_DECAY_PER_SEC = .1

var money = 0 setget set_money
var coolness = 0 setget set_coolness

onready var audio_player = get_node("AudioStreamPlayer")


func _enter_tree():
	Globals.player_ship = self


func _ready():
	if Globals.shop_menu != null:
		Globals.shop_menu.connect("bought_repair", self, "on_ShopMenu_bought_repair")
	else:
		push_warning("[PlayerShip]: Can't find shop menu!")
	connect("body_entered", self, "on_body_entered")
	connect("health_changed", self, "on_health_changed")
	connect("death", GameState, "handle_event", [GameState.Event.PLAYER_DIED])


func set_money(value):
	emit_signal("money_changed", value, money)
	money = value


func set_coolness(value):
	emit_signal("coolness_changed", value, coolness)
	coolness = value


func on_ShopMenu_bought_repair(heal_percent):
	heal(MAX_HEALTH * .01 * heal_percent)


func on_health_changed(current_health, old_health, _max_health):
	if current_health < old_health:
		Announcer.say("ouch")
		audio_player.play()


func on_body_entered(body):
	if not body.is_in_group("projectiles"):
		return
	on_hit_by_projectile(body)
	if body.is_in_group("pinballs"):
		body.bid_farewell()
		body.queue_free()


func on_GameState_changed(new_state, is_debug_skip):
	.on_GameState_changed(new_state, is_debug_skip)
	if new_state == GameState.PREGAME or is_debug_skip:
		set_health(MAX_HEALTH)
