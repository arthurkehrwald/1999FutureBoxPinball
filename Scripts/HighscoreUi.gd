class_name HighscoreUi
extends "res://Scripts/StackedUi.gd"

export var highscore_text_path := NodePath()
onready var highscore_text := get_node(highscore_text_path) as Label

export var new_highscore_intro_path := NodePath()
onready var new_highscore_intro := get_node(new_highscore_intro_path) as UiState

export var display_path := NodePath()
onready var display := get_node(display_path) as UiState

var show_intro_on_active := false


func _ready() -> void:
	if Globals.highscore_tracker != null:
		Globals.highscore_tracker.connect("highscore_updated", self, "_on_HighscoreTracker_highscore_updated")
		set_wants_focus(true)


func _on_enter(params := {}) -> void:
	._on_enter(params)
	if show_intro_on_active:
		show_intro_on_active = false
		set_active_sub_state(new_highscore_intro)
	else:
		set_active_sub_state(display)

func _on_ActiveSubState_exited(params := {}):
	var exit_state := active_sub_state
	._on_ActiveSubState_exited(params)
	if exit_state == new_highscore_intro:
		set_active_sub_state(display)

func _on_HighscoreTracker_highscore_updated(new_highscore: int, old_highscore: int, was_beaten_just_now: bool) -> void:
	if was_beaten_just_now:
		if is_active:
			set_active_sub_state(new_highscore_intro)
		else:
			show_intro_on_active = true
			set_wants_focus(true)
	highscore_text.text = str(new_highscore)
