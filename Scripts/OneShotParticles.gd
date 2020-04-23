extends Spatial

signal finished

onready var delete_timer = get_node("DeleteTimer")


func _ready():
	delete_timer.connect("timeout", self, "on_Timer_timeout")


func activate():
	delete_timer.start()
	for child in get_children():
		var particles = child as Particles
		if particles:
			particles.restart()
			particles.emitting = true


func on_Timer_timeout():
	emit_signal("finished")
