extends Spatial

export var REGENERATION_TIME = 10.0

onready var _damageable = get_node("Damageable")
onready var _health_bar = get_node("HealthBar3D/Viewport/Bar")
onready var _timer = get_node("Timer")
onready var _collision_shape = get_node("HitNotifier/CollisionShape")


func _ready():
	_damageable.connect("is_vulnerable_changed", self, "_on_Damageable_is_vulnerable_changed")
	_damageable.connect("death", self, "_on_Damageable_death")
	_damageable.connect("health_changed", _health_bar, "update_value")
	_timer.connect("timeout", self, "_on_Timer_timeout")


func _on_Damageable_is_vulnerable_changed(value):
	set_visible(value)
	_collision_shape.set_deferred("disabled", !value)


func _on_Damageable_death():
	_timer.start(REGENERATION_TIME)


func _on_Timer_timeout():
	_damageable.set_health(_damageable.MAX_HEALTH)
	_damageable.set_is_vulnerable(true)
