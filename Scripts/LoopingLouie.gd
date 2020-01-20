extends Path

signal landed

export var speed = 1
export var loops_to_fly = 3

var curve_length = 0
var dist_travelled = 0

func _ready():
	curve_length = get_curve().get_baked_length()
	set_process(false)

func _process(delta):
	dist_travelled += speed * delta
	if dist_travelled + speed * delta > curve_length * loops_to_fly:
		$PathFollow.set_offset(0.0)
		dist_travelled = 0
		emit_signal("landed")
		set_process(false)
	else:
		$PathFollow.set_offset($PathFollow.get_offset() + speed * delta)

func _on_PathFollow_louie_triggered():
	set_process(true)
