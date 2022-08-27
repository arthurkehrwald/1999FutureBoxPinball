class_name State
extends Node
# Encapsulates state specific behaviour

signal entered(params)
signal exited(params)

var active_sub_state: State = null setget set_active_sub_state
var is_active := false

export var is_root := false

onready var sub_states: Array = _find_sub_states()
onready var components: Array = _find_components()

func enter(params := {}):
	if is_active:
		return
	is_active = true
	_on_enter(params)

func exit() -> Dictionary:
	if not is_active:
		return {}
	is_active = false
	var params := _on_exit()
	emit_signal("exited", params)
	return params

func _on_enter(params := {}):
	Utils.set_all_process_callbacks_enabled(self, true)
	for component in components:
		component = component as StateComponent
		if component is ExitComponent:
			component.connect("exit_condition_met", self, "exit")
		component.set_is_active(true)
	print("entered %s" % name)
	emit_signal("entered", params)

func _on_exit(passthrough_params := {}) -> Dictionary:
	Utils.set_all_process_callbacks_enabled(self, false)
	if active_sub_state:
		active_sub_state.exit()
	for component in components:
		component = component as StateComponent
		if component is ExitComponent:
			component.disconnect("exit_condition_met", self, "exit")
		component.set_is_active(false)
	print("exited %s" % name)
	return passthrough_params

func set_active_sub_state(value: State, enter_params := {}) -> Dictionary:
	assert(value in sub_states or value == null)
	value = value as State
	var exit_params := {}
	if active_sub_state:
		active_sub_state.disconnect("exited", self, "_on_ActiveSubState_exited")
		exit_params = active_sub_state.exit()
	active_sub_state = value
	if active_sub_state:
		active_sub_state.connect("exited", self, "_on_ActiveSubState_exited")
		active_sub_state.enter(enter_params)
	return exit_params

func _on_ActiveSubState_exited(_params := {}):
	set_active_sub_state(null)

func _find_sub_states_parent() -> Node:
	return get_node_or_null("SubStates")

func _find_sub_states() -> Array:
	var ret := []
	var sub_states_parent := _find_sub_states_parent()
	if not sub_states_parent:
		return []
	for child in sub_states_parent.get_children():
		# Can't use 'child is State' because of Godot bug: https://github.com/godotengine/godot/issues/21461
		child = child as State
		if child:
			ret.append(child)
	return ret

func _find_components_parent() -> Node:
	return get_node_or_null("Components")

func _find_components() -> Array:
	var ret := []
	var components_parent := _find_components_parent()
	if not components_parent:
		return []
	for child in components_parent.get_children():
		# Can't use 'child is State' because of Godot bug: https://github.com/godotengine/godot/issues/21461
		child = child as StateComponent
		if child:
			ret.append(child)
	return ret

func _ready():
	if is_root:
		call_deferred("enter")
	else:
		call_deferred("_on_exit")
