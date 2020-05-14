extends Area


func _ready():
	if Globals.powerup_roulette != null:
		Globals.powerup_roulette.connect("selected_boost", self, "set_deferred",
				["monitoring", true])
		Globals.powerup_roulette.connect("boost_expired", self, "set_deferred",
				["monitoring", false])
