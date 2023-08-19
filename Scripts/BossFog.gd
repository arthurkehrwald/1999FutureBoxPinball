class_name BossFog
extends "res://Scripts/ToggleParticles.gd"

export var path_to_mesh := NodePath()
onready var mesh := get_node(path_to_mesh) as MeshInstance

func toggle(enable):
	.toggle(enable)
	mesh.visible = enable


func _on_Boss_is_active_changed(value):
	toggle(!value)
