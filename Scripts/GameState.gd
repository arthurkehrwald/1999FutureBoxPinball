extends Node

signal state_changed(new_stage, is_debug_skip)

signal objective_one_completed
signal objective_two_completed
signal objectives_changed(objectives)

class SubState:
	signal state_completed(state)
	signal objective_one_completed(state)
	signal objective_two_completed(state)
	
	var NAME = ""
	var OBJECTIVES = {}
	
	func _init(name : String, objectives : Array):
		NAME = name
		OBJECTIVES = objectives
	
	func on_complete():
		emit_signal("state_completed", self)
	
	func handle_event(_event):
		pass


class PostGameState extends SubState:
	func _init(name).(name, ["", ""]):
		pass
	
	func handle_event(event):
		.handle_event(event)
		if event == Event.POSTGAME_FINISHED:
			on_complete()


class PregameState extends SubState:
	func _init().("1-Pregame", ["", ""]):
		pass
	
	func handle_event(event):
		.handle_event(event)
		if event == Event.PREGAME_FINISHED:
			on_complete()


class ExpositionState extends SubState:
	func _init().("2-Exposition", ["To the moon!", ""]):
		pass
	
	func handle_event(event):
		.handle_event(event)
		if event == Event.SHOP_USED:
			emit_signal("objective_one_completed", self)
			on_complete()


class EnemyFleetState extends SubState:
	func _init().("3-EnemyFleet", ["Destroy the enemy fleet!", ""]):
		pass
	
	func handle_event(event):
		.handle_event(event)
		if event == Event.FLEET_DEFEATED:
			emit_signal("objective_one_completed", self)
			on_complete()


class BossFightState extends SubState:
	func _init(name : String).(name, ["Defeat the emperor!", ""]):
		pass
	
	func handle_event(event):
		.handle_event(event)
		if event == Event.BOSS_DIED:
			emit_signal("objective_one_completed", self)


class BossAppearsState extends BossFightState:
	func _init().("4-BossAppears"):
		pass
	
	
	func handle_event(event):
		.handle_event(event)
		if event == Event.BOSS_MISSILES_THRESHOLD or event == Event.BOSS_SHIELD_DESTROYED:
			on_complete()

onready var TESTING_STATE = SubState.new("0-Testing", ["Test123", "Yes"])
onready var VICTORY_STATE = PostGameState.new("9-Victory")
onready var DEFEAT_STATE = PostGameState.new("10-Defeat")

onready var PREGAME_STATE = PregameState.new()
onready var EXPOSITION_STATE = ExpositionState.new()
onready var ENEMY_FLEET_STATE = EnemyFleetState.new()
onready var BOSS_APPEARS_STATE = BossAppearsState.new()
onready var MISSILES_STATE = BossFightState.new("5-Missiles")
onready var TREX_STATE = null
onready var BLACK_HOLE_STATE = null
onready var ECLIPSE_STATE = null

onready var SUB_STATES = [
	PREGAME_STATE,
	EXPOSITION_STATE,
	ENEMY_FLEET_STATE,
	BOSS_APPEARS_STATE,
	MISSILES_STATE
]

enum Event {
	PREGAME_FINISHED,
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

var current_state setget set_current_state, get_current_state


func set_current_state(new_value : SubState, is_debug_skip := false):
	if new_value == null:
		return
	if new_value == current_state:
		return
	if not new_value is SubState:
		return
	var prev_state = current_state
	current_state = new_value
	print("GameState: set to ", current_state.NAME)
	emit_signal("state_changed", current_state, is_debug_skip)
	if (prev_state and prev_state.OBJECTIVES != current_state.OBJECTIVES):
		emit_signal("objectives_changed", current_state.OBJECTIVES)


func get_current_state():
	return current_state


func _ready():
	set_pause_mode(Node.PAUSE_MODE_PROCESS)
	var is_main_scene = get_node_or_null("/root/Main") != null
	if is_main_scene:
		call_deferred("start_game")
	else:
		call_deferred("set_current_state", TESTING_STATE)
	for state in SUB_STATES:
		state.connect("objective_one_completed", self, "on_SubState_objective_one_completed")
		state.connect("objective_two_completed", self, "on_SubState_objective_two_completed")
		state.connect("state_completed", self, "on_SubState_completed")


func start_game():
	set_current_state(SUB_STATES[0])


func on_SubState_objective_one_completed(_state : SubState):
	emit_signal("objective_one_completed")


func on_SubState_objective_two_completed(_state : SubState):
	emit_signal("objective_two_completed")


func on_SubState_completed(state : SubState):
	if SUB_STATES.has(state):
		set_next_state()
	elif state is PostGameState:
		start_game()


func _input(event):
	if event.is_action_type() and event.is_pressed():
		if event.is_action("debug_prev_stage"):
				set_prev_state()
		if event.is_action("debug_next_stage"):
				set_next_state()
		if event.is_action("restart_game"):
				start_game()


func handle_event(var event):
	if current_state:
		current_state.handle_event(event)
	if event == Event.PLAYER_DIED:
		set_current_state(DEFEAT_STATE)
	elif event == Event.BOSS_DIED:
		set_current_state(VICTORY_STATE)


func set_prev_state():
	offset_sub_state_index(-1)


func set_next_state():
	offset_sub_state_index(1)


func offset_sub_state_index(offset : int):
	if SUB_STATES.has(current_state):
		var index = SUB_STATES.find(current_state)
		var new_index = (index + offset) % SUB_STATES.size()
		set_current_state(SUB_STATES[new_index])
