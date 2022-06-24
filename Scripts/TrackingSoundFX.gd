extends Spatial

export var target_lost_delay_seconds = 1.0

onready var prev_pos = get_global_transform().origin

var has_target = false setget set_has_target

func _ready():
	$Timer.connect("timeout", self, "_on_Timer_timeout")

func _process(delta):
	var pos = get_global_transform().origin
	if has_target:
		if prev_pos == pos:
			if $Timer.is_stopped():
				$Timer.start(target_lost_delay_seconds)
		else:
			$Timer.stop()	
	else:
		if prev_pos != pos:
			set_has_target(true)
	prev_pos = pos


func _on_Timer_timeout():
	set_has_target(false)


func set_has_target(val):
	if has_target == val:
		return
	$Timer.stop()
	if val:
		Announcer.say("target_acquired")
	else:
		Announcer.say("signal_lost")
	has_target = val
