class_name PlayerShip
extends "res://Scripts/Damageable.gd"

signal money_changed(new_value, old_value)
signal coolness_changed(new_value, old_value)

export var COOLNESS_DECAY_TIME = 10.0

var money = 0 setget set_money
var coolness = 0 setget set_coolness

onready var audio_player = get_node("AudioStreamPlayer")
onready var coolness_tween = get_node("CoolnessTween")


func _enter_tree():
	Globals.player_ship = self


func _ready():
	connect("health_changed", self, "on_health_changed")


func set_money(value):
	var old_money = money
	money = value
	emit_signal("money_changed", money, old_money)


func set_coolness(value):
	if value > coolness:
		coolness_tween.remove_all()
		coolness_tween.interpolate_property(self, "coolness", value, 0, COOLNESS_DECAY_TIME * value,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		coolness_tween.start()
	var old_coolness = coolness
	coolness = value
	emit_signal("coolness_changed", coolness, old_coolness)


func on_health_changed(current_health, old_health, _max_health):
	if current_health < old_health:
		#Announcer.say("ouch")
		audio_player.play()


func reset_player_stats():
	set_coolness(0)
	set_money(0)
	set_health(MAX_HEALTH)


func on_hit_by_projectile(projectile):
	if not projectile.is_in_group("extra_pinballs"):
		.on_hit_by_projectile(projectile)
	if projectile.is_in_group("pinballs"):
		projectile.on_hit_player()
	if projectile.is_in_group("missiles"):
		projectile.explode()
