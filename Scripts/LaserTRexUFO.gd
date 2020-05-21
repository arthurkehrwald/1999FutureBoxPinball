extends MeshInstance

export(NodePath) var PATH_TO_T_REX = ""

var is_out_of_sight = false

onready var ap = get_node("AnimationPlayer")
onready var t_rex = get_node_or_null(PATH_TO_T_REX)

func _ready():
	if t_rex != null:
		t_rex.connect("is_vulnerable_changed", self, "on_TRex_is_vulnerable_changed")


func on_TRex_is_vulnerable_changed(value):
	if value == is_out_of_sight:
		return
	if value:
		ap.play("fly_away")
	else:
		ap.play_backwards("fly_away")
	is_out_of_sight = value
