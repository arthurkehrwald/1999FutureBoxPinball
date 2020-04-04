class_name Damageable
extends Node

signal is_vulnerable_changed(value)
signal health_changed(health, old_health, max_health)
signal death

const EXPORT_STRING_TO_STATE_ENUM = {
	"Testing": GameState.NONE,
	"Pregame": GameState.PREGAME,
	"Exposition": GameState.EXPOSITION,
	"EnemyFleet": GameState.ENEMY_FLEET,
	"BossAppears": GameState.BOSS_APPEARS,
	"Missiles": GameState.MISSILES,
	"Trex": GameState.TREX,
	"BlackHole": GameState.BLACK_HOLE,
	"Eclipse": GameState.ECLIPSE,
	"Victory": GameState.VICTORY,
	"Defeat": GameState.DEFEAT
}
const MONEY_TEXT_3D_SCENE = preload("res://Scenes/MoneyText3D.tscn")
const DIRECT_HIT_DMG_CALC_SPEED_CUTOFF = 20.0

export var MAX_HEALTH = 100.0
export var PINBALL_DIRECT_HIT_BASE_DAMAGE = 10.0
export var BOMB_DIRECT_HIT_BASE_DAMAGE = 10.0
export var MISSILE_DIRECT_HIT_BASE_DAMAGE = 10.0
export var DIRECT_HIT_SPEED_RELEVANCE = 0.5
export var BOMB_EXPLOSION_BASE_DAMAGE = 10.0
export var MISSILE_EXPLOSION_BASE_DAMAGE = 10.0
export var EXPLOSION_DISTANCE_RELEVANCE = 0.5
export var MONEY_YIELD_PER_DAMAGE = 1.0
export var MONEY_TEXT_HEIGHT = 0.5
export var  IS_VULNERABLE_PER_STAGE = {
	"Testing": true,
	"Pregame": false,
	"Exposition": true,
	"EnemyFleet": true,
	"BossAppears": true,
	"Missiles": true,
	"Trex": true,
	"BlackHole": true,
	"Eclipse": true,
	"Victory": false,
	"Defeat": false
}

var IS_VULNERABLE_PER_GAME_STATE = {}
var health = MAX_HEALTH setget set_health
var is_vulnerable = true setget set_is_vulnerable

onready var _hit_notifier = get_node("../HitNotifier")


func _ready():
	for string_key in IS_VULNERABLE_PER_STAGE.keys():
		var game_state = EXPORT_STRING_TO_STATE_ENUM[string_key]
		IS_VULNERABLE_PER_GAME_STATE[game_state] = IS_VULNERABLE_PER_STAGE[string_key]
	DIRECT_HIT_SPEED_RELEVANCE = clamp(DIRECT_HIT_SPEED_RELEVANCE, 0, 1)
	GameState.connect("state_changed", self, "_on_GameState_changed")
	_hit_notifier.connect("hit_by_pinball_directly", self, "_on_hit_by_pinball_directly")
	_hit_notifier.connect("hit_by_bomb_directly", self, "_on_hit_by_bomb_directly")
	_hit_notifier.connect("hit_by_missile_directly", self, "_on_hit_by_missile_directly")
	_hit_notifier.connect("hit_by_bomb_explosion", self, "_on_hit_by_bomb_explosion")
	_hit_notifier.connect("hit_by_missile_explosion", self, "_on_hit_by_missile_explosion")


func set_is_vulnerable(value):
	if health < 0:
		is_vulnerable = value
		emit_signal("is_vulnerable_changed", value)


func set_health(new_health):
	var old_health = health
	health = clamp(new_health, 0, MAX_HEALTH)
	emit_signal("health_changed", health, old_health, MAX_HEALTH)
	if health == 0:
		emit_signal("death")
		set_is_vulnerable(false)


func heal(amount):
	if is_vulnerable:
		set_health(health + amount)


func take_damage(damage):
	if is_vulnerable:
		set_health(health - damage)
		var money_yield = damage * MONEY_YIELD_PER_DAMAGE
		if money_yield != 0:
			GameState.add_player_money(money_yield)
			var money_text_3d_instance = MONEY_TEXT_3D_SCENE.instance()
			money_text_3d_instance.set_money_amount(money_yield)
			add_child(money_text_3d_instance)
			money_text_3d_instance.translate(Vector3(0, MONEY_TEXT_HEIGHT, 0))


func _calc_direct_hit_damage(var base_damage, var projectile_vel):
	var normalized_projectile_speed = projectile_vel.length() / DIRECT_HIT_DMG_CALC_SPEED_CUTOFF
	normalized_projectile_speed = clamp(normalized_projectile_speed, 0, 1)
	return base_damage * DIRECT_HIT_SPEED_RELEVANCE * sin(PI * normalized_projectile_speed - PI / 2) + base_damage


func _calc_explosion_damage(var base_damage, var explosion_pos, var blast_radius):
	var dist_to_center = explosion_pos - _hit_notifier.get_global_transform().origin
	var normalized_blast_force = 1 - dist_to_center / blast_radius
	return base_damage * EXPLOSION_DISTANCE_RELEVANCE * sin(PI * normalized_blast_force - PI / 2) + base_damage


func _on_hit_by_pinball_directly(_pinball_pos, pinball_vel):
	take_damage(_calc_direct_hit_damage(PINBALL_DIRECT_HIT_BASE_DAMAGE,
			pinball_vel.length()))


func _on_hit_by_bomb_directly(_bomb_pos, bomb_vel):
	take_damage(_calc_direct_hit_damage(BOMB_DIRECT_HIT_BASE_DAMAGE,
			bomb_vel))


func _on_hit_by_missile_directly(_missile_pos, missile_vel):
	take_damage(_calc_direct_hit_damage(MISSILE_DIRECT_HIT_BASE_DAMAGE,
			missile_vel))


func _on_hit_by_bomb_explosion(explosion_pos, blast_radius):
	take_damage(_calc_explosion_damage(BOMB_EXPLOSION_BASE_DAMAGE,
			explosion_pos, blast_radius))


func _on_hit_by_missile_explosion(explosion_pos, blast_radius):
	take_damage(_calc_explosion_damage(MISSILE_EXPLOSION_BASE_DAMAGE,
			explosion_pos, blast_radius))


func _on_GameState_changed(new_state, _is_debug_skip):
	set_is_vulnerable(IS_VULNERABLE_PER_GAME_STATE[new_state])
