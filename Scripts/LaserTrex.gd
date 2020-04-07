extends Spatial

export var LASER_UPTIME = 3.0
export var LASER_DOWNTIME = 5.0

var laser_is_active = false
var time_until_laser_toggle = 0.0

onready var _damageable = get_node("Damageable")
onready var _health_bar = get_node("HealthBar3D/Viewport/Bar")
onready var _gate_collision_shape = get_node("HitNotifier/GateCollisionShape")
onready var _laser_area = get_node("LaserArea")
onready var _timer = get_node("Timer")
onready var _animation_player = get_node("AnimationPlayer")


func _ready():
	_damageable.connect("health_changed", _health_bar, "update_value")
	_damageable.connect("is_vulnerable_changed", _health_bar, "set_visible")
	_damageable.connect("is_vulnerable_changed", self, "_on_Damageable_is_vulnerable_changed")
	_damageable.connect("death", self, "_on_Damageable_death")
	set_process(false)


func _process(delta):
	time_until_laser_toggle -= delta
	if time_until_laser_toggle <= 0:
		laser_set_is_active(!laser_is_active)


func _on_Damageable_is_vulnerable_changed(value):
	if(value):
		Announcer.say("trex_active", true);
	set_target_gate_open(!value)
	laser_set_is_active(false)
	set_process(value)
	#print("LaserTrex: active - ", is_active)


func _on_Damageable_death():
	Announcer.say("trex_defeat", true)


func laser_set_is_active(value):
	_laser_area.set_deferred("monitoring", value)
	_laser_area.set_deferred("monitorable", value)
	_laser_area.set_visible(value)
	_timer.start(LASER_UPTIME if value else LASER_DOWNTIME)
	laser_is_active = value
	#print("LaserTrex: laser active - ", value)


func _on_LaserArea_body_entered(body):
	if body.has_method("_on_destroyed"):
		body._on_destroyed()
	elif body.has_method("explode"):
		body.explode()


func set_target_gate_open(is_open):
	_gate_collision_shape.set_deferred("disabled", is_open)
	if _animation_player.is_playing():
		_animation_player.stop()
	if is_open:
		_animation_player.play("gate_open_anim")
	else:
		_animation_player.play_backwards("gate_open_anim")
