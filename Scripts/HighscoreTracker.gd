class_name HighscoreTracker
extends Node

var save_path := "user://score.save"
var current_score := 0
var highscore := 0 setget _set_highscore, get_highscore
var is_tracking := true setget _set_is_tracking, get_is_tracking
signal highscore_updated(new_highscore, old_highscore, was_beaten_just_now)
signal highscore_tracking_toggled(is_tracking)


func _enter_tree():
	Globals.highscore_tracker = self


func _ready():
	_set_highscore(load_score())
	print("HIGH SCORE: %s" % get_highscore()) 
	if Globals.player_ship != null:
		Globals.player_ship.connect("money_changed", self, "_on_PlayerShip_money_changed")
		Globals.player_ship.connect("death", self, "_on_PlayerShip_death")


func _input(event):
	if event.is_action_released("reset_highscore"):
		reset_highscore()
	if event.is_action_released("toggle_highscore_tracking"):
		_set_is_tracking(!get_is_tracking())


func _set_is_tracking(value: bool) -> void:
	var old = is_tracking
	is_tracking = value
	if is_tracking != old:
		emit_signal("highscore_tracking_toggled", is_tracking)


func get_is_tracking() -> bool:
	return is_tracking


func _on_PlayerShip_money_changed(new_value, _old_value) -> void:
	current_score = new_value


func _on_PlayerShip_death() -> void:
	if is_tracking and current_score > get_highscore():
		_set_highscore(current_score, true)
		save_score(get_highscore())


func _set_highscore(value: int, was_beaten_just_now: bool = false) -> void:
	var old_highscore := highscore
	highscore = value
	emit_signal("highscore_updated", highscore, old_highscore, was_beaten_just_now)


func get_highscore() -> int:
	return highscore


func save_score(score: int) -> void:
	var file = File.new()
	file.open(save_path, File.WRITE)
	file.store_var(score)
	file.close()


func load_score() -> int:
	var file = File.new()
	if file.file_exists(save_path):
		file.open(save_path, File.READ)
		var ret = file.get_var()
		file.close()
		return ret
	else:
		return 0


func reset_highscore() -> void:
	_set_highscore(0)
