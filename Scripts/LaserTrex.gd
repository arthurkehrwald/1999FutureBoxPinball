extends "res://Scripts/Damageable.gd"

export var laser_uptime = 3.0
export var laser_downtime = 5.0

var laser_is_active = false
var time_until_laser_toggle = 0.0

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")

func _ready():
	set_process(false)

func _process(delta):
	time_until_laser_toggle -= delta
	if time_until_laser_toggle <= 0:
		laser_set_active(!laser_is_active)
	pass	

func _on_GameState_global_reset(_is_init):
	set_alive(false)	
		
func _on_LaserTrex_came_to_life():
	set_active(true)

func _on_LaserTrex_death():
	set_active(false)

func set_active(is_active):
	set_target_gate_open(!is_active)
	$HitboxArea.set_deferred("monitoring", is_active)
	$HitboxArea.set_deferred("monitorable", is_active)
	$Bar3D.set_visible(is_active)
	laser_set_active(false)
	set_process(is_active)
	#print("LaserTrex: active - ", is_active)

func laser_set_active(is_active):
	$LaserArea.set_deferred("monitoring", is_active)
	$LaserArea.set_deferred("monitorable", is_active)
	$LaserArea.set_visible(is_active)
	time_until_laser_toggle = laser_uptime if is_active else laser_downtime
	laser_is_active = is_active
	#print("LaserTrex: laser active - ", is_active)

func _on_LaserArea_body_entered(body):
	if body.has_method("_on_LaserTrex_hit"):
		body._on_LaserTrex_hit()
		
func set_target_gate_open(is_open):
	$StaticBody/BottomCollisionShape.set_deferred("disabled", is_open)
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.stop()
	if is_open:
		$AnimationPlayer.play("gate_open_anim")
	else:
		$AnimationPlayer.play_backwards("gate_open_anim")