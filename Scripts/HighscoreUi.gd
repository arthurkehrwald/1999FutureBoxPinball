class_name HighscoreUi
extends "res://Scripts/StackedUi.gd"

export var highscore_text_path := NodePath()
onready var highscore_text := get_node(highscore_text_path) as Label

func _ready() -> void:
	if Globals.highscore_tracker != null:
		Globals.highscore_tracker.connect("highscore_updated", self, "_on_HighscoreTracker_highscore_updated")
		set_wants_focus(true)


func _on_HighscoreTracker_highscore_updated(new_highscore: int, old_highscore: int, was_beaten_just_now: bool) -> void:
	highscore_text.text = str(new_highscore)
