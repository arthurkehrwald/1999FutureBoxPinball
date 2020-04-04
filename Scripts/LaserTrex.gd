extends "res://Scripts/Damageable.gd"

export var laser_uptime = 3.0
export var laser_downtime = 5.0

var laser_is_active = false
var time_until_laser_toggle = 0.0

func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")


func _ready():
	set_process(false)


func _process(delta):
	time_until_laser_toggle -= delta
	if time_until_laser_toggle <= 0:
		laser_set_is_active(!laser_is_active)


func _on_GameState_stage_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage != GameState.ECLIPSE:
		print(GameState.current_stage)
		set_is_active(false)


func _on_is_active_changed():
	if(is_active):
		Announcer.say("trex_active", true);
	set_target_gate_open(!is_active)
	$HealthBar3D.set_visible(is_active)
	laser_set_is_active(false)
	set_process(is_active)
	#print("LaserTrex: active - ", is_active)


func _on_health_changed(_old_health):
	$HealthBar3D/Viewport/Bar.update_value(current_health, MAX_HEALTH)


func _on_death():
	Announcer.say("trex_defeat", true)


func laser_set_is_active(is_active):
	$LaserArea.set_deferred("monitoring", is_active)
	$LaserArea.set_deferred("monitorable", is_active)
	$LaserArea.set_visible(is_active)
	time_until_laser_toggle = laser_uptime if is_active else laser_downtime
	laser_is_active = is_active
	#print("LaserTrex: laser active - ", is_active)


func _on_LaserArea_body_entered(body):
	if body.has_method("_on_destroyed"):
		body._on_destroyed()
	elif body.has_method("explode"):
		body.explode()


func set_target_gate_open(is_open):
	$BottomCollisionShape.set_deferred("disabled", is_open)
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.stop()
	if is_open:
		$AnimationPlayer.play("gate_open_anim")
	else:
		$AnimationPlayer.play_backwards("gate_open_anim")


func _on_Boss_laser_trex_health_threshold_reached():
	set_is_active(true)
