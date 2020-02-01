extends Control

export var auto_glitch = false
export var auto_glitch_rate = 3.0

var rng = RandomNumberGenerator.new()

func _ready():
	#make displacement color rect material unique so that instances can be animated separately
	var unique_material = $displace.get_material().duplicate()
	$displace.set_material(unique_material)
	$AnimationPlayer.play("glitch_idle")
	
	if auto_glitch:
		rng.randomize()
		$Timer.wait_time = rng.randf_range(auto_glitch_rate * .8, auto_glitch_rate * 1.2)
		$Timer.start()

func _on_Timer_timeout():
	$AnimationPlayer2.play("glitchy_glitch")
	$Timer.wait_time = rng.randf_range(auto_glitch_rate * .8, auto_glitch_rate * 1.2)
	$Timer.start()

func glitch_out():
	print("glitch")
	$AnimationPlayer2.play("glitchy_glitch")
