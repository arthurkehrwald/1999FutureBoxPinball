class_name State
extends Node
# Encapsulates state specific behaviour

var active_sub_state: State = null setget set_active_sub_state
onready var sub_states: Array = _find_sub_states()

func enter():
	set_physics_process(true)
	set_process(true)
	set_process_unhandled_input(true)	

func exit():
	set_process(false)
	set_process_unhandled_input(false)
	if active_sub_state:
		active_sub_state.exit()

func set_active_sub_state(value: State):
	assert(value as State)
	assert(is_a_parent_of(value))
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
	if check_is_root():
		# This is a root state
		enter()

func check_is_root() -> bool:
	var parent_state = get_parent() as State
	return parent_state == null
