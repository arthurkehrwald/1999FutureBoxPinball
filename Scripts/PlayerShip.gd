class_name PlayerShip
extends "res://Scripts/Damageable.gd"

signal money_changed(value)
signal coolness_changed(value)

export var SHOP_REPAIR_HEALTH_GAIN = 50.0
export var COOLNESS_DECAY_PER_SEC = .1
export var PATH_TO_SHOP_MENU = "../ShopMenu"

var money = 0 setget set_money
var coolness = 0 setget set_coolness

onready var shop_menu = get_node_or_null(PATH_TO_SHOP_MENU)
onready var audio_player = get_node("AudioStreamPlayer")


func _ready():
	if shop_menu != null:
		shop_menu.connect("bought_repair", self, "on_ShopMenu_bought_repair")
	else:
		push_warning("PlayerShip: Could not find shop menu! ")
	connect("body_entered", self, "on_body_entered")
	connect("health_changed", self, "on_health_changed")
	connect("death", GameState, "handle_event", [GameState.Event.PLAYER_DIED])


func set_money(value):
	money = value
	emit_signal("money_changed", value)


func set_coolness(value):
	coolness = value
	emit_signal("coolness_changed", value)


func on_ShopMenu_bought_repair():
	heal(SHOP_REPAIR_HEALTH_GAIN)


func on_health_changed(current_health, old_health, _max_health):
	if current_health < old_health:
		Announcer.say("ouch")
		audio_player.play()


func on_body_entered(body):
	if not body.is_in_group("projectiles"):
		return
	on_hit_by_projectile(body)
