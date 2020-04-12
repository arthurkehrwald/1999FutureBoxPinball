extends Node

# Balancing variables---------------------
const START_PLAYER_MONEY = 0
const MAX_PLAYER_MONEY = 999
const PLAYER_COOLNESS_DECAY_PER_SEC = 1.0
const BALL_DESTROYED_COST = 200
const BALL_RESET_DELAY = 1.0
#-----------------------------------------

signal state_changed(new_stage, is_debug_skip)

signal objective_one_completed
signal objective_two_completed

signal player_money_changed(new_player_money)
signal player_coolness_changed(new_player_coolness)
signal player_coolness_maxed

enum {
	TESTING,
	PREGAME,
	EXPOSITION,
	ENEMY_FLEET,
	BOSS_APPEARS,
	MISSILES,
	TREX,
	BLACK_HOLE,
	ECLIPSE,
	VICTORY,
	DEFEAT
}

enum Event {
	START_INPUT,
	TRANSMISSION_FINISHED,
	FLEET_DEFEATED,
	SHOP_USED,
	BOSS_HEALTH_PASSED_MISSILES_THRESHOLD,
	BOSS_HEALTH_PASSED_TREX_THRESHOLD,
	BOSS_HEALTH_PASSED_BLACK_HOLE_THRESHOLD,
	BOSS_HEALTH_PASSED_ECLIPSE_THRESHOLD
	BOSS_DIED,
	PLAYER_DIED,
	POSTGAME_FINISHED
}

const NAME_STATE_DICT = {
	"0-Testing": TESTING,
	"1-Pregame": PREGAME,
	"2-Exposition": EXPOSITION,
	"3-EnemyFleet": ENEMY_FLEET,
	"4-BossAppears": BOSS_APPEARS,
	"5-Missiles": MISSILES,
	"6-Trex": TREX,
	"7-BlackHole": BLACK_HOLE,
	"8-Eclipse": ECLIPSE,
	"9-Victory": VICTORY,
	"10-Defeat": DEFEAT
}

var current_state = TESTING

var is_fleet_defeated = false
var has_player_used_shop = false

var global_non_wireframe_mat = preload("res://Materials/mat_for_3d_prints.tres")
var global_wireframe_mat = preload("res://Materials/wireframe_material.tres")


func _ready():
	set_pause_mode(Node.PAUSE_MODE_PROCESS)
	#yield (get_tree().create_timer(1, true), "timeout")
	if get_node_or_null("/root/Main") == null:
		call_deferred("set_state", TESTING)
	else:
		call_deferred("set_state", PREGAME)


func _input(event):
	if event is InputEventKey:
		if event.pressed:
			match event.scancode:
				KEY_0:
					set_state(TESTING, true)
				KEY_1:
					set_state(PREGAME, true)
				KEY_2:
					set_state(EXPOSITION, true)
				KEY_3:
					set_state(ENEMY_FLEET, true)
				KEY_4:
					set_state(BOSS_APPEARS, true)
				KEY_5:
					set_state(MISSILES, true)
				KEY_6:
					set_state(TREX, true)
				KEY_7:
					set_state(BLACK_HOLE, true)
				KEY_8:
					set_state(ECLIPSE, true)
				KEY_9:
					set_state(VICTORY, true)
				_:
					handle_event(Event.START_INPUT)


func handle_event(var event):
	match current_state:
		TESTING:
			pass
		PREGAME:
			if event == Event.START_INPUT:
				set_state(EXPOSITION)
		EXPOSITION:
			if event == Event.TRANSMISSION_FINISHED:
				set_state(ENEMY_FLEET)
		ENEMY_FLEET:
			if event == Event.FLEET_DEFEATED:
				is_fleet_defeated = true
				emit_signal("objective_one_completed")
				if has_player_used_shop:
					set_state(BOSS_APPEARS)
			if event == Event.USED_SHOP:
				has_player_used_shop = true
				emit_signal("objective_two_completed")
				if is_fleet_defeated:
					set_state(BOSS_APPEARS)
		BOSS_APPEARS:
			if event == Event.BOSS_MISSILES_THRESHOLD:
				set_state(MISSILES)
		MISSILES:
			if event == Event.BOSS_TREX_THRESHOLD:
				set_state(TREX)
		TREX:
			if event == Event.BOSS_BLACK_HOLE_THRESHOLD:
				set_state(BLACK_HOLE)
		BLACK_HOLE:
			if event == Event.BOSS_ECLIPSE_THRESHOLD:
				set_state(ECLIPSE)
		ECLIPSE:
			pass
		VICTORY:
			if event == Event.POSTGAME_FINISHED:
				set_state(PREGAME)
		DEFEAT:
			if event == Event.POSTGAME_FINISHED:
				set_state(PREGAME)


func set_state(new_state, is_debug_skip = false):
	print("GameState: set to ", new_state)
	set_global_eclipse_materials(new_state == ECLIPSE)
	if new_state == ENEMY_FLEET:
		has_player_used_shop = false
		is_fleet_defeated = false
	current_state = new_state
	emit_signal("state_changed", new_state, is_debug_skip)


func set_global_eclipse_materials(is_eclipse):
	if is_eclipse:
		global_non_wireframe_mat.albedo_color = Color.black
		global_wireframe_mat.albedo_color = Color(133, 0, 255, 255)
		global_wireframe_mat.set_blend_mode(SpatialMaterial.BLEND_MODE_ADD)
	else:
		global_non_wireframe_mat.albedo_color = Color.white
		global_wireframe_mat.albedo_color = Color(0, 255, 58, 255)
		global_wireframe_mat.set_blend_mode(SpatialMaterial.BLEND_MODE_SUB)


func set_player_money(value):
	player_money = clamp(value, 0, MAX_PLAYER_MONEY)
	emit_signal("player_money_changed", player_money)


func set_player_coolness(value):
	if player_coolness < 100 and value >= 100:
		emit_signal("player_coolness_maxed")
	player_coolness = clamp(value, 0, 100)
	emit_signal("player_coolness_changed", player_coolness)
