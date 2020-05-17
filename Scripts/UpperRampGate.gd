extends StaticBody

onready var mesh = get_node("Mesh")
onready var collision_shape = get_node("CollisionShape")


func toggle(value):
	mesh.visible = value
	collision_shape.set_deferred("disabled", !value)
