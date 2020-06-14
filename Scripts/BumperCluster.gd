extends Spatial

export var TIME_LIMIT = 0.0
export var BUMP_LIMIT = 0
export var DISABLED_DURATION = 3.0

var bumpers = []
var bump_count = 0

onready var disable_timer = get_node("DisableTimer")
onready var enable_timer = get_node("EnableTimer")


func _ready():
	disable_timer.connect("timeout", self, "toggle_bumpers", [false])
	enable_timer.connect("timeout", self, "toggle_bumpers", [true])
	for child in get_children():
		if child.name.matchn("Bumper*"):
			bumpers.push_back(child)
			child.connect("bumped", self, "on_Bumper_bumped")


func toggle_bumpers(value):
	for bumper in bumpers:
		bumper.set_deferred("monitoring", value)
	disable_timer.stop()
	bump_count = 0
	if not value:
		enable_timer.start(DISABLED_DURATION)


func on_Bumper_bumped():
	if TIME_LIMIT > 0 and disable_timer.is_stopped():
		disable_timer.start(TIME_LIMIT)
	bump_count += 1
	if BUMP_LIMIT > 0 and bump_count >= BUMP_LIMIT:
		toggle_bumpers(false)
