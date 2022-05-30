extends Node

signal state_changed(new_stage, is_debug_skip)

signal objective_one_completed
signal objective_two_completed
signal objectives_changed(objectives)

class SubState extends Node:
	signal state_completed(state)
	signal objective_one_completed(state)
	signal objective_two_completed(state)
	
	var NAME = ""
	var OBJECTIVES = {}
	
	func _init(name : String, objectives : Array):
		NAME = name
		OBJECTIVES = objectives
	
	func enter():
		pass
	
	func exit():
		pass
	
	func on_complete():
		emit_signal("state_completed", self)
	
	func handle_event(_event):
		pass


class TimeLimitedState extends SubState:
	var timer = null
	
	func _init(name : String, objectives : Array, time_limit : float).(name, objectives):
		timer = Timer.new()
		timer.set_wait_time(time_limit)
		timer.one_shot = true
		timer.connect("timeout", self, "on_Timer_timeout")
		add_child(timer)
	
	func enter():
		.enter()
		timer.start()
	
	func exit():
		timer.stop()

	func on_Timer_timeout():
		on_complete()


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


class ExpositionState extends TimeLimitedState:
	func _init().("2-Exposition", ["To the moon!", ""], 30):
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

onready var SPECIAL_STATES = [
	TESTING_STATE,
	VICTORY_STATE,
	DEFEAT_STATE
]

onready var PREGAME_STATE = PregameState.new()
onready var EXPOSITION_STATE = ExpositionState.new()
onready var ENEMY_FLEET_STATE = EnemyFleetState.new()
onready var BOSS_APPEARS_STATE = BossAppearsState.new()
onready var MISSILES_STATE = BossFightState.new("5-Missiles")
onready var TREX_STATE = null
onready var BLACK_HOLE_STATE = null
onready var ECLIPSE_STATE = null

onready var SEQ_STATES = [
	PREGAME_STATE,
	EXPOSITION_STATE,
	ENEMY_FLEET_STATE,
	BOSS_APPEARS_STATE,
	MISSILES_STATE
]

onready var ALL_STATES = SPECIAL_STATES + SEQ_STATES

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
	if prev_state:
		prev_state.exit()
	current_state = new_value
	current_state.enter()
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
	for state in ALL_STATES:
		add_child(state)
		state.connect("objective_one_completed", self, "on_SubState_objective_one_completed")
		state.connect("objective_two_completed", self, "on_SubState_objective_two_completed")
		state.connect("state_completed", self, "on_SubState_completed")


func start_game():
	set_current_state(SEQ_STATES[0])


func on_SubState_objective_one_completed(_state : SubState):
	emit_signal("objective_one_completed")


func on_SubState_objective_two_completed(_state : SubState):
	emit_signal("objective_two_completed")


func on_SubState_completed(state : SubState):
	if current_state != state:
		return
	if SEQ_STATES.has(state):
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
		if event.is_action("debug_enter_test_state"):
			set_current_state(TESTING_STATE)


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
	if SEQ_STATES.has(current_state):
		var index = SEQ_STATES.find(current_state)
		var new_index = (index + offset) % SEQ_STATES.size()
		set_current_state(SEQ_STATES[new_index])
