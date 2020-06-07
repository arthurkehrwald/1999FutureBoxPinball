extends StaticBody

export(NodePath) var PATH_TO_T_REX = ""

onready var t_rex = get_node_or_null(PATH_TO_T_REX)
onready var mesh = get_node("Mesh")
onready var collision_shape = get_node("CollisionShape")


func _ready():
	if t_rex != null:
		t_rex.connect("is_vulnerable_changed", self, "on_TRex_is_vulnerable_changed")


func on_TRex_is_vulnerable_changed(value):
	mesh.visible = not value
	collision_shape.set_deferred("disabled", value)
