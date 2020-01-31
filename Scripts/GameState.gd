extends Node

# Balancing variables---------------------
const START_PLAYER_MONEY = 200
const MAX_PLAYER_MONEY = 1000
const PLAYER_COOLNESS_DECAY_PER_SEC = 10.0
const BALL_DESTROYED_COST = 200
const BALL_RESET_DELAY = 1.0
#-----------------------------------------

signal global_reset(is_init)
signal spawn_ball
signal player_money_changed(new_player_money)
signal player_money_maxed
signal player_coolness_changed(new_player_coolness)
signal player_coolness_maxed
signal laser_trex_set_alive(is_alive)
signal boss_shield_set_alive(is_alive)
signal enemy_fleet_set_active(is_active)
signal storm_set_active(is_active)
signal moon_gate_set_active(is_active)

signal set_wireframe_material( material)
signal set_collision_object_material(material)
signal toggle_nightmode(toggle)

enum state {PREGAME, ENEMY_FLEET, BOSS_START, SOLAR_ECLIPSE}
var current_state = state.PREGAME

var ball_spawn_pos = Vector3(0, 0, 0)

var player_money = 0 setget set_player_money
var player_coolness = 0 setget set_player_coolness
var nightmode_enabled = false
var laser_trex_gates_are_open = false
var balls_on_field = 0
var balls_are_remote_controlled = true

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
	local_init()

func _ready():
	set_pause_mode(Node.PAUSE_MODE_PROCESS)
	call_deferred("global_init", true)

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		get_tree().set_pause(!get_tree().is_paused())
	processDebugInput()
	set_player_coolness(player_coolness - PLAYER_COOLNESS_DECAY_PER_SEC * delta)
	
func global_init(is_on_start):
	emit_signal("global_reset", is_on_start)
	emit_signal("set_wireframe_material", pink_unlit)
	emit_signal("set_collision_object_material", light_blue)
	emit_signal("toggle_nightmode", true)
	emit_signal("spawn_ball")
	emit_signal("enemy_fleet_set_active", true)
	set_player_money(START_PLAYER_MONEY)
	nightmode_enabled = true
	
func local_init():
	current_state = state.PREGAME
	
func set_state(next_state):
	match next_state:
		state.PREGAME:
			pass
		state.ENEMY_FLEET:
			emit_signal("spawn_ball")
			emit_signal("enemy_fleet_set_active")
		state.BOSS_START:
			emit_signal("boss_shield_set_alive")
		state.SOLAR_ECLIPSE:
			pass
	current_state = next_state

func on_PlayerShip_ball_drained(ball, player_health):
	if player_health > 0:
		if balls_on_field == 1:
			ball.set_visible(true)
			ball.set_locked(false)
			ball.delayed_teleport(ball_spawn_pos)
		else:
			ball.delete()	
			
func on_EnemyFleet_destroyed():
	pass
	
func on_PlayerShip_death():
	pass
	
func on_Boss_death():
	pass
	
func set_player_money(new_player_money):
	if player_money < MAX_PLAYER_MONEY and new_player_money >= MAX_PLAYER_MONEY:
		emit_signal("player_money_maxed")
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

func _on_ShopMenu_bought_remote_control():
	pass
	
func processDebugInput():
	if Input.is_action_just_pressed("test_reload_scene"):
		get_tree().reload_current_scene()
		local_init()
		global_init(false)
		
	if Input.is_action_just_pressed("global_reset"):
		print("GameState: global reset")
		local_init()
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
		
	if Input.is_action_just_pressed("gate_test"):
		laser_trex_gates_are_open = !laser_trex_gates_are_open
		emit_signal("laser_trex_gates_set_open", laser_trex_gates_are_open)
