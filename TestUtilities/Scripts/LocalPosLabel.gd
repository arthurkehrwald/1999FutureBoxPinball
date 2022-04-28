extends Label

onready var parent = get_node("..")
const format = "Tracker:\nX %.4f\nY %.4f\nZ %.4f"

func _process(_delta):
	if (!parent):
		return;
	if (!parent is Spatial):
		return
	
	var pos = parent.transform.origin
	text = format % [pos.x, pos.y, pos.z]
