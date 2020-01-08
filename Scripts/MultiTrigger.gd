extends Spatial

export var all_hit_color = Color()
export var score_value = 500

var child_trigger_count = 0
var child_triggers_hit = 0

signal all_hit(all_hit_color)
signal all_reset

# Called when the node enters the scene tree for the first time.
func _ready():
	child_trigger_count = get_child_count() - 1 # Every child except for the reset timer is a trigger

func _on_ChildTrigger_hit():
	child_triggers_hit += 1
	if child_triggers_hit == child_trigger_count:
		$ResetTimer.start()
		emit_signal("all_hit", all_hit_color)
		GameState.set_score(GameState.current_score + score_value)

func _on_ChildTrigger_reset():
	child_triggers_hit -= 1

func _on_ResetTimer_timeout():
	$ResetTimer.stop()
	child_triggers_hit = 0
	emit_signal("all_reset")
