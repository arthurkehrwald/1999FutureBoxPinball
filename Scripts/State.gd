class_name State
extends Node
# Encapsulates state specific behaviour

signal entered()
signal exited(params)

var active_sub_state: State = null setget set_active_sub_state
var is_active := false
var is_active_sub_state_changing := false

export var is_root := false

onready var sub_states: Array = _find_sub_states_in_children(self)
onready var components: Array = _find_components_in_children(self)

func enter(params := {}):
	if is_active:
		return
	is_active = true
	print("entered %s" % name)
	_on_enter(params)
	emit_signal("entered")

func exit() -> Dictionary:
	if not is_active:
		return {}
	is_active = false
	var params := _on_exit()
	print("exited %s" % name)
	emit_signal("exited", params)
	return params

func _on_enter(_params := {}):
	Utils.set_all_process_callbacks_enabled(self, true)
	for component in components:
		component = component as StateComponent
		if component is ExitComponent:
			component.connect("exit_condition_met", self, "exit")
		component.set_is_active(true)

func _on_exit(passthrough_params := {}) -> Dictionary:
	Utils.set_all_process_callbacks_enabled(self, false)
	if active_sub_state:
		active_sub_state.exit()
	for component in components:
		component = component as StateComponent
		if component is ExitComponent and component.is_connected("exit_condition_met", self, "exit"):
			component.disconnect("exit_condition_met", self, "exit")
		component.set_is_active(false)
	return passthrough_params

func set_active_sub_state(value: State, enter_params := {}) -> Dictionary:#
	# Prevent strange things from happening
	if not is_active and not value == null:
		push_error("Attempted to change active sub state on inactive state. BIG nono!")
		assert(false)
		return {}
	if is_active_sub_state_changing:
		push_error("Attempted to change active sub state during transition. BIG nono!")
		assert(false)
		return {}
	is_active_sub_state_changing = true
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
	is_active_sub_state_changing = false
	return exit_params

func _on_ActiveSubState_exited(_params := {}):
	set_active_sub_state(null)

func _find_sub_states_in_children(parent) -> Array:
	var ret := []
	for child in parent.get_children():
		if child as State != null:
			if not child.is_root:
				ret.append(child)
		else:
			ret += _find_sub_states_in_children(child)
	return ret


func _find_components_in_children(parent) -> Array:
	var ret := []
	for child in parent.get_children():
		var comp = child as StateComponent
		var state = child as State
		if comp:
			ret.append(child)
		elif not state:
			ret += _find_components_in_children(child)
	return ret

func _ready():
	if is_root:
		call_deferred("enter")
	else:
		call_deferred("_on_exit")
