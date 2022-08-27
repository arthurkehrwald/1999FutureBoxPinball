class_name PowerupRoulette
extends "res://Scripts/StackedUi.gd"

const ICON_SCENE = preload("res://Scenes/PowerupIcon.tscn")

export var path_to_spin_state := NodePath()
export var path_to_moon := NodePath()

var powerups := []
var powerup_icons := []
var unscaled_icon_width: float
var last_hit_info: HitInfo = null

onready var spin_state := get_node(path_to_spin_state) as PowerupRouletteSpinState
onready var moon := get_node(path_to_moon) as MoonShop

class HitInfo:
	var speed: float
	var decay: float
	
func _enter_tree():
	Globals.powerup_roulette = self

func _ready():
	moon.connect("hit", self, "_on_Moon_hit")
	spin_state.connect("selected_powerup", self, "_on_SpinState_selected_powerup")

func _on_enter(_params := {}):
	if last_hit_info:
		start_roulette(last_hit_info.speed, last_hit_info.decay)
		last_hit_info = null

func register_powerup(powerup : Powerup):
	if powerups.has(powerup):
		push_error("Powerup %s is already registered! Cannot register" % powerup.powerup_name)
		return
	powerups.push_back(powerup)


func unregister_powerup(powerup: Powerup):
	if !powerups.has(powerup):
		push_error("Powerup %s is not registered! Cannot unregister" % powerup.powerup_name)
		return
	powerups.erase(powerup)


func has_at_least_one_viable_powerup() -> bool:
	for powerup in powerups:
		if powerup.probability > 0:
			return true
	return false


func _on_Moon_hit(speed: float, decay: float):
	if has_at_least_one_viable_powerup():
		if is_active:
			start_roulette(speed, decay)
		else:
			last_hit_info = HitInfo.new()
			last_hit_info.speed = speed
			last_hit_info.decay = decay
			set_wants_focus(true)

func start_roulette(speed: float, decay: float):
	var params = {
		"start_speed": speed,
		"speed_decay": decay,
		"powerups": powerups
	}
	.set_active_sub_state(spin_state, params)


func _on_SpinState_selected_powerup(powerup: Powerup):
	powerup.activate()


func _on_ActiveSubState_exited(_exit_params := {}):
	match active_sub_state:
		spin_state:
			set_wants_focus(false)
			exit()
		_:
			._on_ActiveSubState_exited()
