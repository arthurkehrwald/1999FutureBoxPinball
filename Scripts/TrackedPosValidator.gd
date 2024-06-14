class_name TrackedPosValidator
extends Spatial

signal is_pos_valid_changed(is_valid)
signal is_pos_recent_changed(is_pos_recent)
signal is_pos_plausible_changed(is_pos_plausible)

export var target_lost_delay_seconds = 1.0
export var max_plausible_pos = Vector3(15, 15, 50)
export var min_plausible_pos = Vector3(-15, -1, -9)

onready var prev_pos = get_global_transform().origin

var is_pos_valid = false setget _set_is_pos_valid, get_is_pos_valid
var is_pos_recent = false setget _set_is_pos_recent, get_is_pos_recent
var is_pos_plausible = false setget _set_is_pos_plausible, get_is_pos_plausible

func _ready():
	$Timer.connect("timeout", self, "_on_Timer_timeout")


func _process(_delta) -> void:
	_set_is_pos_recent(_check_is_pos_recent())
	_set_is_pos_plausible(_check_is_pos_plausible())
	

func _check_is_pos_plausible() -> bool:
	var pos = get_global_transform().origin
	return pos.x > min_plausible_pos.x\
		and pos.x < max_plausible_pos.x\
		and pos.y > min_plausible_pos.y\
		and pos.y < max_plausible_pos.y\
		and pos.z > min_plausible_pos.z\
		and pos.z < max_plausible_pos.z


func _check_is_pos_recent() -> bool:
	var pos = get_global_transform().origin
	if is_pos_recent and prev_pos == pos and $Timer.is_stopped():
		$Timer.start(target_lost_delay_seconds)
	if prev_pos != pos and not $Timer.is_stopped():
		$Timer.stop()
	var ret = prev_pos != pos
	prev_pos = pos
	return ret


func _on_Timer_timeout() -> void:
	_set_is_pos_recent(false)


func _set_is_pos_recent(val) -> void:
	if is_pos_recent == val:
		return
	if val:
		Announcer.say("target_acquired")
	else:
		Announcer.say("signal_lost")
	is_pos_recent = val
	emit_signal("is_pos_recent_changed", self, is_pos_recent)
	_update_validity()

func _set_is_pos_plausible(is_plausible: bool) -> void:
	if is_pos_plausible == is_plausible:
		return
	is_pos_plausible = is_plausible
	emit_signal("is_pos_plausible_changed", self, is_pos_plausible)
	_update_validity()
	
func _update_validity() -> void:
	_set_is_pos_valid(is_pos_plausible && is_pos_recent)

func _set_is_pos_valid(is_valid: bool) -> void:
	if is_pos_valid == is_valid:
		return
	is_pos_valid = is_valid
	emit_signal("is_pos_valid_changed", self, is_pos_valid)
	
func get_is_pos_valid() -> bool:
	return is_pos_valid

func get_is_pos_recent() -> bool:
	return is_pos_recent
	
func get_is_pos_plausible() -> bool:
	return is_pos_plausible
