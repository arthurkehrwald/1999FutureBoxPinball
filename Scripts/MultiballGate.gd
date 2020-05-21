extends StaticBody

onready var mesh = get_node("Mesh")
onready var collision_shape = get_node("CollisionShape")


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")


func toggle(value):
	mesh.visible = value
	collision_shape.set_deferred("disabled", not value)


func on_GameState_changed(new_state, _is_debug_skip):
	toggle(new_state < GameState.MISSILES)
