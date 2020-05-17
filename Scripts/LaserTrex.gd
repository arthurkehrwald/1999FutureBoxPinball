extends "res://Scripts/Damageable.gd"

export var LASER_UPTIME = 3.0
export var LASER_DOWNTIME = 5.0
export(NodePath) var PATH_TO_GATE = ""
export(NodePath) var PATH_TO_CAGE = ""

var laser_is_active = false
var time_until_laser_toggle = 0.0

onready var health_bar = get_node("TrexBar3D/Viewport/TrexBar/HealthBar")
onready var laser_area = get_node("LaserArea")
onready var laser_toggle_timer = get_node("LaserToggleTimer")
onready var gate = get_node_or_null(PATH_TO_GATE)
onready var cage = get_node_or_null(PATH_TO_CAGE)

func _enter_tree():
	Globals.trex = self


func _ready():
	connect("health_changed", health_bar, "update_value")
	connect("is_vulnerable_changed", health_bar.get_parent(), "set_visible")
	connect("is_vulnerable_changed", self, "on_is_vulnerable_changed")
	connect("death", self, "on_death")
	laser_toggle_timer.connect("timeout", self, "on_LaserToggleTimer_timeout")

func on_is_vulnerable_changed(value):
	if(value):
		Announcer.say("trex_active", true);
	if value:
		laser_toggle_timer.start(LASER_DOWNTIME)
	else:
		set_laser_is_active(false)
		laser_toggle_timer.stop()
	if gate != null:
		gate.toggle(!value)
	if cage != null:
		cage.toggle(!value)


func on_death():
	Announcer.say("trex_defeat", true)


func set_laser_is_active(value):
	laser_area.set_deferred("monitoring", value)
	laser_area.set_deferred("monitorable", value)
	laser_area.set_visible(value)
	laser_toggle_timer.start(LASER_UPTIME if value else LASER_DOWNTIME)
	laser_is_active = value


func on_LaserToggleTimer_timeout():
	set_laser_is_active(!laser_is_active)
