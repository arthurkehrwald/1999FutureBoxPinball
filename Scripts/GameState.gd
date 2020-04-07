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
signal spawn_ball

enum {
	NONE,
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

var current_state = NONE

var player_money = 0
var player_coolness = 0 setget set_player_coolness
var nightmode_enabled = false
var balls_on_field = 0
var player_ship = null

var _is_fleet_defeated = false
var _has_player_used_shop = false

var plunger_progress = 0.0

var global_non_wireframe_mat = preload("res://Materials/mat_for_3d_prints.tres")
var global_wireframe_mat = preload("res://Materials/wireframe_material.tres")


func _ready():
	set_pause_mode(Node.PAUSE_MODE_PROCESS)
	#yield (get_tree().create_timer(1, true), "timeout")
	if get_node_or_null("/root/Main") == null:
		call_deferred("_set_state", NONE)
	else:
		call_deferred("_set_state", PREGAME)


func _process(delta):
	if Input.is_action_just_pressed("start"):
		handle_event(Event.START_INPUT)
	processDebugInput()
	if player_coolness > 0:
		set_player_coolness(player_coolness - PLAYER_COOLNESS_DECAY_PER_SEC * delta)


func global_init():
	nightmode_enabled = false
	_set_state(PREGAME, false)


func handle_event(var event):
	match current_state:
		NONE:
			pass
		PREGAME:
			if event == Event.START_INPUT:
				_set_state(EXPOSITION)
		EXPOSITION:
			if event == Event.TRANSMISSION_FINISHED:
				_set_state(ENEMY_FLEET)
		ENEMY_FLEET:
			if event == Event.FLEET_DEFEATED:
				_is_fleet_defeated = true
				emit_signal("objective_one_completed")
				if _has_player_used_shop:
					_set_state(BOSS_APPEARS)
			if event == Event.USED_SHOP:
				_has_player_used_shop = true
				emit_signal("objective_two_completed")
				if _is_fleet_defeated:
					_set_state(BOSS_APPEARS)
		BOSS_APPEARS:
			if event == Event.BOSS_MISSILES_THRESHOLD:
				_set_state(MISSILES)
		MISSILES:
			if event == Event.BOSS_TREX_THRESHOLD:
				_set_state(TREX)
		TREX:
			if event == Event.BOSS_BLACK_HOLE_THRESHOLD:
				_set_state(BLACK_HOLE)
		BLACK_HOLE:
			if event == Event.BOSS_ECLIPSE_THRESHOLD:
				_set_state(ECLIPSE)
		ECLIPSE:
			pass
		VICTORY:
			if event == Event.POSTGAME_FINISHED:
				_set_state(PREGAME)
		DEFEAT:
			if event == Event.POSTGAME_FINISHED:
				_set_state(PREGAME)


func _set_state(new_state, is_debug_skip = false):
	print("GameState: set to ", new_state)
	set_global_eclipse_materials(new_state == ECLIPSE)
	if new_state == ENEMY_FLEET:
		_has_player_used_shop = false
		_is_fleet_defeated = false
	current_state = new_state
	emit_signal("state_changed", new_state, is_debug_skip)


func set_global_eclipse_materials(is_ECLIPSE):
	if is_ECLIPSE:
		global_non_wireframe_mat.albedo_color = Color.black
		global_wireframe_mat.albedo_color = Color(133, 0, 255, 255)
		global_wireframe_mat.set_blend_mode(SpatialMaterial.BLEND_MODE_ADD)
	else:
		global_non_wireframe_mat.albedo_color = Color.white
		global_wireframe_mat.albedo_color = Color(0, 255, 58, 255)
		global_wireframe_mat.set_blend_mode(SpatialMaterial.BLEND_MODE_SUB)


func add_player_money(amount):
	player_money = clamp(player_money + amount, 0, MAX_PLAYER_MONEY)
	emit_signal("player_money_changed", player_money)


func set_player_coolness(new_player_coolness):
	if player_coolness < 100 and new_player_coolness >= 100:
		emit_signal("player_coolness_maxed")
	player_coolness = clamp(new_player_coolness, 0, 100)
	emit_signal("player_coolness_changed", player_coolness)


func processDebugInput():
	if Input.is_action_just_pressed("pause"):
		get_tree().is_paused = !get_tree().is_paused()
	
	if Input.is_action_just_pressed("test_reload_scene"):
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("debug_goto_pregame"):
		_set_state(PREGAME, true)
	
	if Input.is_action_just_pressed("debug_goto_exposition"):
		_set_state(EXPOSITION, true)
	
	if Input.is_action_just_pressed("debug_goto_fleet"):
		_set_state(ENEMY_FLEET, true)
	
	if Input.is_action_just_pressed("debug_goto_boss_begin"):
		_set_state(BOSS_APPEARS, true)	
	
	if Input.is_action_just_pressed("debug_goto_ECLIPSE"):
		_set_state(ECLIPSE, true)		
	
	if Input.is_action_just_pressed("debug_spawn_ball"):
		emit_signal("spawn_ball")
