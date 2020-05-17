extends Node

signal state_changed(new_stage, is_debug_skip)

signal objective_one_completed
signal objective_two_completed
signal objectives_changed(objectives)

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
	BOSS_SHIELD_DESTROYED,
	BOSS_MISSILES_THRESHOLD,
	BOSS_TREX_THRESHOLD,
	BOSS_BLACK_HOLE_THRESHOLD,
	BOSS_ECLIPSE_THRESHOLD,
	BLACK_HOLE_EXPANDED,
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

const OBJECTIVES = {
	TESTING: ["Test123", "Yes"],
	PREGAME: ["", ""],
	EXPOSITION: ["To the moon!", ""],
	ENEMY_FLEET: ["Destroy the enemy fleet!", ""],
	BOSS_APPEARS: ["Defeat the emperor!", ""],
	MISSILES: ["Defeat the emperor!", ""],
	TREX: ["Defeat the emperor!", ""],
	BLACK_HOLE: ["Defeat the emperor!", ""],
	ECLIPSE: ["Defeat the emperor!", ""],
	VICTORY: ["", ""],
	DEFEAT: ["", ""]
}

var current_state = TESTING

var has_player_used_shop = false
var is_black_hole_expanding = false

var global_non_wireframe_mat = preload("res://Materials/mat_for_3d_prints.tres")
var global_wireframe_mat = preload("res://Materials/wireframe_material.tres")


func _ready():
	#yield(get_tree().create_timer(.1), "timeout")
	set_pause_mode(Node.PAUSE_MODE_PROCESS)
	if get_node_or_null("/root/Main") == null:
		call_deferred("set_state", TESTING)
	else:
		call_deferred("set_state", PREGAME)
	#Engine.time_scale = .2
	#emit_signal("objectives_changed", OBJECTIVES[current_state])


func _input(event):
	if event is InputEventKey and event.pressed:
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
	if event == Event.PLAYER_DIED:
		set_state(DEFEAT)
	elif event == Event.BOSS_DIED:
		set_state(VICTORY)
	match current_state:
		TESTING:
			pass
		PREGAME:
			if event == Event.START_INPUT:
				set_state(EXPOSITION)
		EXPOSITION:
			if event == Event.SHOP_USED:
				emit_signal("objective_one_completed")
			if event == Event.TRANSMISSION_FINISHED and has_player_used_shop:
				set_state(ENEMY_FLEET)
		ENEMY_FLEET:
			if event == Event.FLEET_DEFEATED:
				emit_signal("objective_one_completed")
				set_state(BOSS_APPEARS)
		BOSS_APPEARS:
			if event == Event.BOSS_MISSILES_THRESHOLD or event == Event.BOSS_SHIELD_DESTROYED:
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
			if event == Event.BLACK_HOLE_EXPANDED:
				set_global_eclipse_materials(true)
		VICTORY:
			if event == Event.POSTGAME_FINISHED:
				set_state(PREGAME)
		DEFEAT:
			if event == Event.POSTGAME_FINISHED:
				set_state(PREGAME)


func set_state(new_state, is_debug_skip = false):
	print("GameState: set to ", new_state)
	if new_state < ECLIPSE:
		set_global_eclipse_materials(false)
	if new_state == EXPOSITION:
		has_player_used_shop = false
	emit_signal("state_changed", new_state, is_debug_skip)
	if OBJECTIVES[current_state] != OBJECTIVES[new_state]:
		emit_signal("objectives_changed", OBJECTIVES[new_state])
	current_state = new_state


func set_global_eclipse_materials(is_eclipse):
	if is_eclipse:
		global_non_wireframe_mat.albedo_color = Color.black
		#global_wireframe_mat.albedo_color = Color(133, 0, 255, 255)
		#global_wireframe_mat.set_blend_mode(SpatialMaterial.BLEND_MODE_ADD)
	else:
		global_non_wireframe_mat.albedo_color = Color.gray
		#global_wireframe_mat.albedo_color = Color(0, 255, 58, 255)
		#global_wireframe_mat.set_blend_mode(SpatialMaterial.BLEND_MODE_SUB)
