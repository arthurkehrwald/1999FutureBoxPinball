extends CanvasItem


func _ready() -> void:
	if Globals.highscore_tracker != null:
		visible = !Globals.highscore_tracker.get_is_tracking()
		Globals.highscore_tracker.connect("highscore_tracking_toggled", self, "_on_HighscoreTracker_highscore_tracking_toggled")
	else:
		visible = true

func _on_HighscoreTracker_highscore_tracking_toggled(is_tracking: bool) -> void:
	visible = !is_tracking
