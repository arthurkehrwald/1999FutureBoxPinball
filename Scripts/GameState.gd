extends Node

# Balancing variables---------------------
const START_PLAYER_MONEY = 0
const MAX_PLAYER_MONEY = 1000
const PLAYER_COOLNESS_DECAY_PER_SEC = 10.0
const BALL_DESTROYED_COST = 200
const BALL_RESET_DELAY = 1.0
#-----------------------------------------

signal stage_changed(new_stage, is_debug_skip)

signal objective_one_completed
signal objective_two_completed

signal paused
signal unpaused

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

enum stage {NONE, PREGAME, EXPOSITION, ENEMY_FLEET, BOSS_BEGIN, SOLAR_ECLIPSE}
var current_stage = stage.NONE

var ball_spawn_pos = Vector3(0, 0, 0)

var player_money = 0 setget set_player_money
var player_coolness = 0 setget set_player_coolness
var nightmode_enabled = false
var balls_on_field = 0

var is_fleet_defeated = false
var has_player_used_shop = false

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
	call_deferred("set_stage", stage.PREGAME, false)

func _process(delta):
	if current_stage == stage.PREGAME and Input.is_action_just_pressed("start"):
		set_stage(stage.EXPOSITION, false)
		
	if Input.is_action_just_pressed("pause"):
		set_paused(!get_tree().is_paused())
	processDebugInput()
	if player_coolness > 0:
		set_player_coolness(player_coolness - PLAYER_COOLNESS_DECAY_PER_SEC * delta)
	
func global_init():
	emit_signal("set_wireframe_material", pink_unlit)
	emit_signal("set_collision_object_material", light_blue)
	emit_signal("toggle_nightmode", false)
	set_player_money(START_PLAYER_MONEY)
	nightmode_enabled = false
	set_stage(stage.PREGAME, false)
			
func set_stage(new_stage, is_debug_skip):
	print("GameState: set stage to: ", new_stage)
	if new_stage == stage.PREGAME:
		set_player_money(START_PLAYER_MONEY)
	elif new_stage == stage.ENEMY_FLEET:
		has_player_used_shop = false
		is_fleet_defeated = false
	current_stage = new_stage
	emit_signal("stage_changed", new_stage, is_debug_skip)
		
func on_TransmissionHUD_finished():
	if current_stage == stage.EXPOSITION:
		set_stage(stage.ENEMY_FLEET, false)
		
func on_PlayerShip_ball_drained(ball, player_health):
	if player_health > 0:
		if balls_on_field == 1:
			ball.set_visible(true)
			ball.set_locked(false)
			ball.delayed_teleport(ball_spawn_pos)
		else:
			ball.delete()	
	
func on_EnemyFleet_defeated():
	if current_stage == stage.ENEMY_FLEET:
		if not is_fleet_defeated:
			is_fleet_defeated = true
			emit_signal("objective_one_completed")
		if has_player_used_shop:
			set_stage(stage.BOSS_BEGIN, false)

func on_ShopMenu_player_bought_anything():
	if current_stage == stage.ENEMY_FLEET:
		if not has_player_used_shop:
			has_player_used_shop = true
			emit_signal("objective_two_completed")
		if is_fleet_defeated:
			set_stage(stage.BOSS_BEGIN, false)		
			
func on_Boss_hit_solar_eclipse_threshold():
	set_stage(stage.SOLAR_ECLIPSE, false)

func on_PlayerShip_death():
	pass
	
func on_Boss_death():
	pass
	
func set_paused(is_paused):
	get_tree().paused = is_paused
	if is_paused:
		emit_signal("paused")
	else:
		emit_signal("unpaused")
	
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
		global_init()
		
	if Input.is_action_just_pressed("debug_goto_pregame"):
		print("Gamestage: global reset")
		global_init()
		
	if Input.is_action_just_pressed("debug_goto_exposition"):
		set_stage(stage.EXPOSITION, true)
		
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

	if Input.is_action_just_pressed("debug_spawn_ball"):
		emit_signal("spawn_ball")
