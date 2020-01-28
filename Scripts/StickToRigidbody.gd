extends Spatial

var parent

func _ready():
	parent = get_node("../Rigidbody")
	
func _physics_process(_delta):
	var t = get_transform()
	t.origin = parent.get_transform().origin
	set_transform(t)
