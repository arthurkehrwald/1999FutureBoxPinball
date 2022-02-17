extends Spatial

export var sensitivity = 0.001

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(delta):
	$Label.text = "X:%.2f\nY:%.2f" % [transform.origin.x, transform.origin.z]

func _input(event):
	if event is InputEventMouseMotion:
		translate(Vector3.RIGHT * event.relative.x * 0.001 * sensitivity)
		translate(Vector3.BACK * event.relative.y * 0.001 * sensitivity)
