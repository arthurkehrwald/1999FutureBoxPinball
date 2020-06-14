extends "res://Scripts/Damageable.gd"

export var LASER_UPTIME = 3.0
export var LASER_DOWNTIME = 5.0

var laser_is_active = false
var time_until_laser_toggle = 0.0

onready var health_bar = get_node("TrexBar3D/Viewport/TrexBar/HealthBar")
onready var laser_area = get_node("LaserArea")
onready var laser_toggle_timer = get_node("LaserToggleTimer")
onready var growl_audio_player = get_node("GrowlAudioPlayer")
onready var laser_audio_player = get_node("LaserAudioPlayer")


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


func on_death():
	Announcer.say("trex_defeat", true)


func set_laser_is_active(value):
	laser_area.set_deferred("monitoring", value)
	laser_area.set_deferred("monitorable", value)
	laser_area.set_visible(value)
	laser_toggle_timer.start(LASER_UPTIME if value else LASER_DOWNTIME)
	laser_is_active = value
	if value:
		laser_audio_player.play()
		growl_audio_player.play()
	else:
		laser_audio_player.stop()


func on_LaserToggleTimer_timeout():
	set_laser_is_active(!laser_is_active)
