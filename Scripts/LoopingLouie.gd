extends Path

export var COOLNESS_VALUE = 1.0
export var SPEED = 3
export var LOOPS_TO_FLY = 1

var curve_length = 0
var dist_travelled = 0
var is_flying = false

onready var audio_player = get_node("AudioStreamPlayer")
onready var path_follow = get_node("PathFollow")


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")
	if Globals.player_ship == null:
		push_warning("[LoopingLouie] Can't find player! Will not contribute to "
				+ "coolness.")
	curve_length = get_curve().get_baked_length()
	set_process(false)


func _process(delta):
	dist_travelled += SPEED * delta
	if dist_travelled + SPEED * delta > curve_length * LOOPS_TO_FLY:
		land()
	else:
		path_follow.set_offset(path_follow.get_offset() + SPEED * delta)


func on_GameState_changed(new_state, is_debug_skip):
	if is_debug_skip or new_state == GameState.PREGAME:
		land()


func start_flying():
	is_flying = true
	if Globals.player_ship != null:
		Globals.player_ship.set_coolness(Globals.player_ship.coolness + COOLNESS_VALUE)
	audio_player.play()
	Announcer.say("looping_louie")
	set_process(true)


func land():
	is_flying = false
	path_follow.set_offset(0.0)
	dist_travelled = 0
	set_process(false)
