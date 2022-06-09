extends "res://Scripts/ToggleParticles.gd"

onready var mesh = get_node("MeshInstance3")
onready var col_layer_when_enabled = call("get_collision_layer")


func _on_Boss_is_vulnerable_changed(value):
	toggle(!value)
	mesh.visible = !value
	call("set_collision_layer", 0 if value else col_layer_when_enabled)
