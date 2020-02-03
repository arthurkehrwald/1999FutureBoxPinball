extends Timer

signal start
signal time_left_changed(new_time_left)

export var remote_control_duration = 15.0
export var time_left_report_rate = .1

func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")

func _ready():
	set_wait_time(remote_control_duration)
	$ReportTimer.set_wait_time(time_left_report_rate)
	
func _on_GameState_stage_changed(_new_stage, _is_debug_skip):
	if !is_stopped():
		$ReportTimer.stop()
		stop()

func _on_ShopMenu_bought_remote_control():
	stop()
	$ReportTimer.stop()
	set_process(true)
	start()
	emit_signal("start")
	$ReportTimer.start()
	
func _on_ReportTimer_timeout():
	emit_signal("time_left_changed", time_left / remote_control_duration)
	$ReportTimer.start()
