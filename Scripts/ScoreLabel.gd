extends Label

func _ready():
	text = "Score: %s"%GameState.current_score
	GameState.connect("score_changed", self,"_on_GameState_score_changed")

func _on_GameState_score_changed(new_score):
	text = "Score: %s"%new_score
