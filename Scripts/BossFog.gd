extends "res://Scripts/ToggleParticles.gd"

onready var boss = get_node("..")
onready var mesh = get_node("MeshInstance3")
onready var collision_shape = get_node("CollisionShape")


func _ready():
	if boss is Boss:
		boss.connect("is_vulnerable_changed", self, "on_Boss_is_vulnerable_changed")


func on_Boss_is_vulnerable_changed(value):
	toggle(!value)
	mesh.visible = !value
	collision_shape.set_deferred("disabled", value)
