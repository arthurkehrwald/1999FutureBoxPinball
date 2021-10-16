extends Label

func _ready():
	text = "Reserve Balls: %s"%GameState.reserve_balls
	GameState.connect("reserve_balls_changed", self,"_on_GameState_reserve_balls_changed")

func _on_GameState_reserve_balls_changed(new_reserve_balls):
	text = "Reserve Balls: %s"%new_reserve_balls
