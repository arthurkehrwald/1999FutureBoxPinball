class_name HighscoreTracker
extends Node

var save_path := "user://score.save"
var current_score := 0
var highscore := 0 setget _set_highscore, get_highscore
signal highscore_updated(new_highscore, old_highscore, was_beaten_just_now)

func _enter_tree():
	Globals.highscore_tracker = self

func _ready():
	_set_highscore(load_score())
	print("HIGH SCORE: %s" % get_highscore()) 
	if Globals.player_ship != null:
		Globals.player_ship.connect("money_changed", self, "_on_PlayerShip_money_changed")		
		Globals.player_ship.connect("death", self, "_on_PlayerShip_death")


func _on_PlayerShip_money_changed(new_value, _old_value) -> void:
	current_score = new_value


func _on_PlayerShip_death() -> void:
	if current_score > get_highscore():
		_set_highscore(current_score)
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
