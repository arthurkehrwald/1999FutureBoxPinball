extends Node

var save_path := "user://score.save"
var current_score := 0
var highscore := 0 setget _set_highscore, get_highscore
signal new_highscore(new_highscore, old_highscore)

func _ready():
	highscore = load_score()
	print("HIGH SCORE: %s" % highscore) 
	if Globals.player_ship != null:
		Globals.player_ship.connect("money_changed", self, "_on_PlayerShip_money_changed")		
		Globals.player_ship.connect("death", self, "_on_PlayerShip_death")


func _on_PlayerShip_money_changed(new_value, old_value) -> void:
	current_score = new_value


func _on_PlayerShip_death() -> void:
	if current_score > highscore:
		var old_highscore := highscore
		highscore = current_score
		save_score(highscore)
		print("HIGH SCORE: %s" % highscore)
		emit_signal("new_highscore", highscore, old_highscore)


func _set_highscore(value: int) -> void:
	highscore = value


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
