extends KinematicBody

onready var anim_player = get_node("AnimationPlayer")


func _ready():
	if Globals.powerup_roulette != null:
		Globals.powerup_roulette.connect("selected_stopper", anim_player, "play", ["up"])
		Globals.powerup_roulette.connect("stopper_expired", anim_player, "play", ["down"])
