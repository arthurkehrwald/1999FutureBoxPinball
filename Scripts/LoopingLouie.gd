extends Path

signal landed

export var speed = 3
export var loops_to_fly = 1

var curve_length = 0
var dist_travelled = 0

func _enter_tree():
	GameState.connect("state_changed", self, "_on_GameState_changed")

func _ready():
	curve_length = get_curve().get_baked_length()
	set_process(false)

func _process(delta):
	dist_travelled += speed * delta
	if dist_travelled + speed * delta > curve_length * loops_to_fly:
		land()
	else:
		$PathFollow.set_offset($PathFollow.get_offset() + speed * delta)

func _on_GameState_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.PREGAME:
		land()

func _on_PathFollow_louie_triggered():
	GameState.set_player_coolness(100)
	$AudioStreamPlayer.play()
	Announcer.say("looping_louie")
	set_process(true)

func land():
	$PathFollow.set_offset(0.0)
	dist_travelled = 0
	emit_signal("landed")
	set_process(false)
