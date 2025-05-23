extends Path

export var COOLNESS_VALUE = 1.0
export var SPEED = 3
export var LOOPS_TO_FLY = 1

var curve_length = 0
var dist_travelled = 0
var is_flying = false

onready var audio_player = get_node("AudioStreamPlayer")
onready var path_follow = get_node("PathFollow")
onready var trail = get_node("PathFollow/Spatial/LoopingLouieTrailFX")


func _ready():
	if Globals.player_ship == null:
		push_warning("[LoopingLouie] Can't find player! Will not contribute to "
				+ "coolness.")
	curve_length = get_curve().get_baked_length()
	set_process(false)
	trail.emitting = false


func _process(delta):
	dist_travelled += SPEED * delta
	if dist_travelled + SPEED * delta > curve_length * LOOPS_TO_FLY:
		land()
	else:
		path_follow.set_offset(path_follow.get_offset() + SPEED * delta)


func start_flying():
	is_flying = true
	if Globals.player_ship != null:
		Globals.player_ship.set_coolness(Globals.player_ship.coolness + COOLNESS_VALUE)
	audio_player.play()
	Announcer.say("looping_louie")
	set_process(true)
	trail.emitting = true


func land():
	is_flying = false
	path_follow.set_offset(0.0)
	dist_travelled = 0
	set_process(false)
	trail.emitting = false
