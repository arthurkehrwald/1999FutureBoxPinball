class_name State
extends Node
# Encapsulates state specific behaviour

signal entered
signal exited

var active_sub_state: State = null setget set_active_sub_state
onready var sub_states: Array = _find_sub_states()

func enter():
	set_physics_process(true)
	set_process(true)
	set_process_unhandled_input(true)
	set_process_input(true)
	emit_signal("entered")

func exit():
	set_physics_process(false)
	set_process(false)
	set_process_unhandled_input(false)
	set_process_input(false)
	if active_sub_state:
		active_sub_state.exit()
	emit_signal("exited")

func set_active_sub_state(value: State):
	assert(value in sub_states)
	if value == active_sub_state:
		return
	if active_sub_state:
		active_sub_state.exit()
	active_sub_state = value
	active_sub_state.enter()

func _find_sub_states() -> Array:
	var ret := []
	for child in get_children():
		# Can't use 'child is State' because of Godot bug: https://github.com/godotengine/godot/issues/21461
		child = child as State
		if child:
			ret.append(child)
	return ret

func _ready():
	yield(get_tree().root, "ready")
	if check_is_root():
		enter()

func check_is_root() -> bool:
	var parent_state = get_parent() as State
	return parent_state == null
