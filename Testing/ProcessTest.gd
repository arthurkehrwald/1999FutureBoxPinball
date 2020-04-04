extends Spatial

var processing_enabled = false
var process_timer = 1

signal processing_timer_expired


#func _enter_tree():
	#GameState.connect("reset_ball", self, "_on_GameState_reset")


func _ready():
	set_process(false)
	var timer = get_tree().create_timer(3)
	timer.time_left = 10
	timer.connect("timeout", self, "timer_finished")	


func _process(delta):
	process_timer -= delta
	#print("processing ", process_timer)
	if process_timer <= 0:
		set_process(false)
		processing_enabled = false
		print("processing finished")
		emit_signal("processing_timer_expired")


func _on_GameState_reset():
	print("toggle process")
	process_timer = 1
	processing_enabled = !processing_enabled
	set_process(processing_enabled)
	yield (self, "processing_timer_expired")
	print("reset finished")


func timer_finished():
	print("timer_finished")


func _on_Timer_timeout():
	print("YEET")
