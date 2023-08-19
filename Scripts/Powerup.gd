class_name Powerup
extends Node

signal is_active_changed(is_active)

export(String) var powerup_name := "Powerup"
export(int) var probability := 1
export(float) var duration := 0.0
export(Texture) var icon
export(Texture) var instructions

var is_active := false
var timer : SceneTreeTimer = null

func _ready():
	if Globals.powerup_roulette:
		Globals.powerup_roulette.register_powerup(self)


func _exit_tree():
	if Globals.powerup_roulette:
		Globals.powerup_roulette.unregister_powerup(self)


func activate():
	if is_active:
		return
	is_active = true
	print("Activated powerup %s" % powerup_name)	
	if duration > 0.0:
		timer = get_tree().create_timer(duration)
		timer.connect("timeout", self, "_on_timeout")
	emit_signal("is_active_changed", true)


func deactivate():
	if !is_active:
		return
	if timer != null:
		timer.disconnect("timeout", self, "_on_timeout")
		timer = null
	is_active = false
	print("Deactivated powerup %s" % powerup_name)
	emit_signal("is_active_changed", false)


func get_time_left() -> float:
	if timer != null:
		return timer.get_time_left()
	return 0.0 


func _on_timeout():
	deactivate()
