extends Node

const FADE_DB_REDUCTION = 50

export var crossfade_duration = 5.0

var active_player = null
var fade_out_player = null
var fade_progress = 0
var active_player_normal_db = 0
var fade_out_normal_db = 0
var is_crossfade_ongoing = false

onready var track_1_player = get_node("Track1Player")
onready var track_2_player = get_node("Track2Player")
onready var track_3_player = get_node("Track3Player")
onready var active_player_in_state = {
	GameState.TESTING_STATE: null,
	GameState.PREGAME_STATE: track_1_player,
	GameState.EXPOSITION_STATE: track_1_player,
	GameState.ENEMY_FLEET_STATE: track_2_player,
	GameState.BOSS_APPEARS_STATE: track_3_player,
	GameState.MISSILES_STATE: track_3_player,
	GameState.TREX_STATE: track_2_player,
	GameState.BLACK_HOLE_STATE: track_3_player,
	GameState.ECLIPSE_STATE: track_3_player,
	GameState.VICTORY_STATE: track_3_player,
	GameState.DEFEAT_STATE: null
}


func _enter_tree():
	GameState.connect("state_changed", self, "on_GameState_changed")


func _ready():
	set_process(false)


func _process(delta):
	fade_progress += delta / crossfade_duration
	if fade_progress < 1.0:
		active_player.volume_db = lerp(active_player_normal_db - FADE_DB_REDUCTION, active_player_normal_db, fade_progress)
		fade_out_player.volume_db = lerp(fade_out_normal_db, fade_out_normal_db - FADE_DB_REDUCTION, fade_progress)
	else:
		fade_out_player.stop()
		fade_out_player.volume_db = fade_out_normal_db
		fade_out_player = null
		fade_progress = 0
		stop_other_players(active_player)
		set_process(false)


func on_GameState_changed(new_state, _is_debug_skip):
	if active_player_in_state[new_state] == null:
		return
	if active_player != active_player_in_state[new_state]:
		if fade_out_player != null:
			fade_out_player.volume_db = fade_out_normal_db
			fade_out_player.stop()
			fade_out_player = null
			fade_progress = 1 - fade_progress
		if active_player != null:
			fade_out_player = active_player 
			fade_out_normal_db = active_player_normal_db
			set_process(true)
		active_player = active_player_in_state[new_state]
		active_player.play()
		active_player_normal_db = active_player.volume_db


func stop_other_players(player):
	match active_player:
		track_1_player:
			track_2_player.stop()
			track_3_player.stop()
		track_2_player:
			track_1_player.stop()
			track_3_player.stop()
		track_3_player:
			track_1_player.stop()
			track_2_player.stop()
