class_name StateMachine
extends Node
# Can change its behaviour by switching between a number of states. Delegates
# inputs to its active state which can respond by calling the transition method.

signal state_changed(previous, new)

export(NodePath) var initial_state

onready var _state = get_node(initial_state)


func _ready():
	_state._enter()


func transition_to(target_state_path, info = {}):
	assert(is_a_parent_of(target_state_path))
	var target_state = get_node(target_state_path)
	_state.exit()
	target_state.enter(info)
	emit_signal("state_changed", _state.name, target_state.name)
	_state = target_state
