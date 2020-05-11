extends MeshInstance

var x_pos = 0

onready var tween = get_node("Tween")
onready var timer = get_node("Timer")

func _ready():
	tween.follow_property(timer, "time_left", timer.time_left, self, "x_pos", timer.time_left, Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()


func _process(delta):
	set_transform(Transform(Basis.IDENTITY, Vector3(x_pos, 0, 0)))
