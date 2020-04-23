extends Area

func _ready():
	connect("body_entered", self, "on_body_entered")


func on_body_entered(body):
	if body.is_in_group("projectiles"):
		body.on_entered_laser_area()
