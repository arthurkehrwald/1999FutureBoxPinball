class_name CameraTrackingToggler
extends Spatial

export var tracked_pos_validator_path := NodePath()
export var tracked_parent_path := NodePath()
export var non_tracked_parent_path := NodePath()

onready var tracked_pos_validator := get_node(tracked_pos_validator_path) as TrackedPosValidator
onready var tracked_parent := get_node(tracked_parent_path) as Spatial
onready var non_tracked_parent := get_node(non_tracked_parent_path) as Spatial

func _ready() -> void:
	call_deferred("on_tracked_pos_validator_is_pos_plausible_changed", tracked_pos_validator.get_is_pos_plausible())
	set_disable_scale(true)
	tracked_pos_validator.connect("is_pos_plausible_changed", self, "on_tracked_pos_validator_is_pos_plausible_changed")


func on_tracked_pos_validator_is_pos_plausible_changed(is_valid: bool) -> void:
	if is_valid:
		_set_parent(tracked_parent)
	else:
		_set_parent(non_tracked_parent)
	set_translation(Vector3.ZERO)
	set_rotation(Vector3.ZERO)
	set_scale(Vector3.ONE)

func _set_parent(parent: Spatial) -> void:
	if get_parent() == parent:
		return
	if get_parent() != null:
		get_parent().remove_child(self)
	parent.add_child(self)
	self.set_owner(parent)
