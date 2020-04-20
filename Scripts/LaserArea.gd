extends Area

func _ready():
	connect("body_entered", self, "on_body_entered")


func on_body_entered(body):
	if not body.is_in_group("projectiles"):
		push_warning(Globals.USELESS_COLLISION_WARNING_FORMAT_STRING % [name, body.name])
		return
	body.on_entered_laser_area()
