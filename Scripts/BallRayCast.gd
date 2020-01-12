extends RayCast

var ball

func _ready():
	ball = get_node("../Ball")
	
func _physics_process(_delta):
	var t = get_transform()
	t.origin = ball.get_transform().origin
	set_transform(t)
