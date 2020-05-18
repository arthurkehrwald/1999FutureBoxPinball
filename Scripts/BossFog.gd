extends "res://Scripts/ToggleParticles.gd"

onready var boss = get_node("..")
onready var mesh = get_node("MeshInstance3")
onready var collision_shape = get_node("CollisionShape")
onready var col_layer_when_enabled = call("get_collision_layer")


func _ready():
	if boss is Boss:
		boss.connect("is_vulnerable_changed", self, "on_Boss_is_vulnerable_changed")


func on_Boss_is_vulnerable_changed(value):
	toggle(!value)
	mesh.visible = !value
	call("set_collision_layer", 0 if value else col_layer_when_enabled)
