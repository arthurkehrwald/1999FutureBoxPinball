extends "res://Scripts/Damageable.gd"

export var FLIGHT_DURATION = 5.0
export var SPIN_SPEED_MULTIPLIER = 1.0
export var SPIN_SPEED_FALLOFF = 1.4
export var impulse_strength = 3.0

var current_spin_speed = 0.0

var spin_axis = Vector3(1, 0, 0)
var is_flying = false
var is_spinning = false

#possible inputs for the state machine
enum In{
	FLY_ANIM_DONE,
	DEATH,
	DAMAGED,
	SCALE_ANIM_DONE,
	STOPPED_SPINNING,
	IMPACT
}

var movement_state = null
var scale_state = null
var spin_state = null

func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")


func _ready():
	movement_state = $MovementStates/Stationary
	movement_state.enter()
	scale_state = $ScaleStates/Small
	scale_state.enter()
	spin_state = $SpinStates/Still
	spin_state.enter()
	set_process(false)


func handle_input(var input, var opt_info = null):
	movement_state.handle_input(input, opt_info)
	scale_state.handle_input(input, opt_info)
	spin_state.handle_input(input, opt_info)


func _on_GameState_stage_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.stage.PREGAME:
#		set_process(false)
#		is_spinning = false
#		if $AnimationPlayer.is_playing():
#			$AnimationPlayer.stop()
		set_active(true)
		
	if new_stage == GameState.stage.BOSS_BEGIN or new_stage == GameState.stage.SOLAR_ECLIPSE:
			set_active(true)
	else:
			set_active(false)


#func _on_is_active_changed():
#	if is_active:
#		if not is_spinning:
#			if is_flying:
#				$AnimationPlayer.play_backwards("moon_spectral_transition")
#			else:
#				set_visible(false)	
#		is_flying = false	
#	else:
#		Announcer.say("moon_destroyed")
#		set_visible(true)
#		set_deferred("is_flying", true)


func _on_impact(var body):
	._on_impact(body)	
	handle_input(In.IMPACT, body)


func _on_health_changed(old_health):
	if is_active and current_health < old_health:
		handle_input(In.DAMAGED)


func  _on_death():
	handle_input(In.DEATH)


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"moon_fly":
			handle_input(In.FLY_ANIM_DONE)
		"moon_scale":
			handle_input(In.SCALE_ANIM_DONE)
