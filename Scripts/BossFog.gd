extends "res://Scripts/ToggleParticles.gd"

onready var mesh = get_node("MeshInstance3")
onready var col_layer_when_enabled = call("get_collision_layer")

var is_boss_vulnerable = false
var is_boss_dead = false

func _on_Boss_is_vulnerable_changed(value):
	is_boss_vulnerable = value
	evaluate()


func _on_Boss_health_changed(health, old_health, max_health):
	is_boss_dead = health <= 0
	evaluate()


func evaluate():
	toggle(!is_boss_vulnerable and !is_boss_dead)


func toggle(enable):
	.toggle(enable)
	mesh.visible = enable
	call("set_collision_layer", col_layer_when_enabled if enable else 0)
