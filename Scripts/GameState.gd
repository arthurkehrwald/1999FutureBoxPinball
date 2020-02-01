extends Node

# Balancing variables---------------------
const START_PLAYER_MONEY = 200
const MAX_PLAYER_MONEY = 1000
const PLAYER_COOLNESS_DECAY_PER_SEC = 10.0
const BALL_DESTROYED_COST = 200
const BALL_RESET_DELAY = 1.0
#-----------------------------------------

signal global_reset(is_init)
signal pregame_began
signal exposition_began
signal enemy_fleet_fight_began
signal bossfight_began
signal solar_eclipse_began

signal objective_one_completed
signal objective_two_completed

signal player_money_changed(new_player_money)
signal player_coolness_changed(new_player_coolness)
signal player_coolness_maxed
signal spawn_ball
#signal laser_trex_set_alive(is_alive)
#signal boss_shield_set_alive(is_alive)
#signal enemy_fleet_set_active(is_active)
#signal storm_set_active(is_active)
#signal moon_gate_set_active(is_active)
#signal objective_changed(new_objective_one, new_objective_two)

signal set_wireframe_material( material)
signal set_collision_object_material(material)
signal toggle_nightmode(toggle)

enum state {NONE, PREGAME, EXPOSITION, ENEMY_FLEET, BOSS_BEGIN, SOLAR_ECLIPSE}
var current_state = state.NONE

var ball_spawn_pos = Vector3(0, 0, 0)

var player_money = 0 setget set_player_money
var player_coolness = 0 setget set_player_coolness
var nightmode_enabled = false
var balls_on_field = 0

var is_objective_one_complete = false
var is_objective_two_complete = false

var plunger_progress = 0.0

var pink_unlit = preload("res://Materials/pink_unlit.tres")
var ultraviolet_subtractive = preload("res://Materials/ultraviolet_subtractive.tres")
var ultraviolet_additive = preload("res://Materials/ultraviolet_additive.tres")
var white_unlit = preload("res://Materials/white_unlit.tres")
var black_unlit = preload("res://Materials/black_unlit.tres")
var light_blue = preload("res://Materials/light_blue_test.tres")

var collision_object_materials = [white_unlit, black_unlit, light_blue]
var current_collision_object_material_index = 0
var wireframe_materials = [pink_unlit, ultraviolet_subtractive, ultraviolet_additive]
var current_wireframe_material_index = 0

func _enter_tree():
	pass

func _ready():
	set_pause_mode(Node.PAUSE_MODE_PROCESS)
	call_deferred("global_init", true)

func _process(delta):
	if current_state == state.PREGAME and Input.is_action_just_pressed("start"):
		advance_state()
		
	if Input.is_action_just_pressed("pause"):
		get_tree().set_pause(!get_tree().is_paused())
	processDebugInput()
	if player_coolness > 0:
		set_player_coolness(player_coolness - PLAYER_COOLNESS_DECAY_PER_SEC * delta)
	
func global_init(is_on_start):
	emit_signal("global_reset", is_on_start)
	emit_signal("set_wireframe_material", pink_unlit)
	emit_signal("set_collision_object_material", light_blue)
	emit_signal("toggle_nightmode", true)
	set_player_money(START_PLAYER_MONEY)
	nightmode_enabled = true
	current_state = state.NONE
	advance_state()
			
func advance_state():
	is_objective_one_complete = false
	is_objective_two_complete = false
	match current_state:
		state.NONE:
			current_state = state.PREGAME
			emit_signal("pregame_began")
		state.PREGAME:
			current_state = state.EXPOSITION
			emit_signal("exposition_began")
		state.EXPOSITION:
			current_state = state.ENEMY_FLEET
			emit_signal("enemy_fleet_fight_began")
		state.ENEMY_FLEET:
			is_objective_two_complete = true
			current_state = state.BOSS_BEGIN
			emit_signal("bossfight_began")
		state.BOSS_BEGIN:
			current_state = state.BOSS_BEGIN
			emit_signal("solar_eclipse_began")
		state.SOLAR_ECLIPSE:
			pass
		
func on_TransmissionHUD_finished():
	if current_state == state.EXPOSITION:
		advance_state()
		
func on_PlayerShip_ball_drained(ball, player_health):
	if player_health > 0:
		if balls_on_field == 1:
			ball.set_visible(true)
			ball.set_locked(false)
			ball.delayed_teleport(ball_spawn_pos)
		else:
			ball.delete()	
			
func on_objective_one_complete():
	is_objective_one_complete = true
	emit_signal("objective_one_completed")
	if is_objective_two_complete:
		advance_state()
		
func on_objective_two_complete():
	is_objective_two_complete = true
	emit_signal("objective_two_completed")
	if is_objective_one_complete:
		advance_state()
	
func on_PlayerShip_death():
	pass
	
func on_Boss_death():
	pass
	
func set_player_money(new_player_money):
	player_money = clamp(new_player_money, 0, MAX_PLAYER_MONEY)
	emit_signal("player_money_changed", player_money)

func set_player_coolness(new_player_coolness):
	if player_coolness < 100 and new_player_coolness >= 100:
		emit_signal("player_coolness_maxed")
	player_coolness = clamp(new_player_coolness, 0, 100)
	emit_signal("player_coolness_changed", player_coolness)

func _on_MultiballShip_ball_locked():
	if balls_on_field <= 0:
		emit_signal("spawn_ball")
	
func processDebugInput():
	if Input.is_action_just_pressed("test_reload_scene"):
		get_tree().reload_current_scene()
		global_init(false)
		
	if Input.is_action_just_pressed("global_reset"):
		print("GameState: global reset")
		global_init(false)
		
	if Input.is_action_just_pressed("test_cycle_materials"):
		if current_collision_object_material_index < collision_object_materials.size() - 1:
			current_collision_object_material_index += 1
		else:
			current_collision_object_material_index = 0
		emit_signal("set_collision_object_material", collision_object_materials[current_collision_object_material_index])
	
	if Input.is_action_just_pressed("test_cycle_wireframe_materials"):
		if current_wireframe_material_index < wireframe_materials.size() - 1:
			current_wireframe_material_index += 1
		else:
			current_wireframe_material_index = 0
		emit_signal("set_wireframe_material", wireframe_materials[current_wireframe_material_index])
	
	if Input.is_action_just_pressed("toggle_nightmode"):
		nightmode_enabled = !nightmode_enabled
		emit_signal("toggle_nightmode", nightmode_enabled)
