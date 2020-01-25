extends Node

# Balancing variables---------------------
const START_PLAYER_MONEY = 200
const MAX_PLAYER_MONEY = 1000
const BALL_DESTROYED_COST = 200
const BALL_RESET_DELAY = 1.0
#-----------------------------------------

signal global_reset
signal spawn_ball
signal boss_died
signal player_died
signal player_money_changed(new_player_money)
signal player_money_maxed
signal activate_enemy_ships
signal laser_trex_set_active(is_active)

signal set_wireframe_material( material)
signal set_collision_object_material(material)
signal toggle_nightmode(toggle)

var player_money = 100 setget set_player_money
var nightmode_enabled = false
var balls_on_field = 0

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
	global_init()
	
func global_init():
	emit_signal("global_reset")
	emit_signal("set_wireframe_material", pink_unlit)
	emit_signal("set_collision_object_material", light_blue)
	emit_signal("toggle_nightmode", true)
	emit_signal("spawn_ball")
	emit_signal("activate_enemy_ships")
	emit_signal("laser_trex_set_active", true)
	nightmode_enabled = true
	
func local_init():
	set_player_money(START_PLAYER_MONEY)

func on_PlayerShip_ball_drained(ball, player_health):
	if player_health > 0:
		if balls_on_field == 1:
			ball.back_to_spawn()
		else:
			ball.delete()	
	
func on_PlayerShip_death():
	emit_signal("player_died")
	
func on_Boss_death():
	emit_signal("boss_died")
	
func set_player_money(new_player_money):
	player_money = clamp(new_player_money, 0, MAX_PLAYER_MONEY)
	emit_signal("player_money_changed", player_money)
	if player_money == MAX_PLAYER_MONEY:
		emit_signal("player_money_maxed")

func _on_MultiballShip_ball_locked():
	if balls_on_field <= 0:
		emit_signal("spawn_ball")

func _process(_delta):
	processDebugInput()
	
func processDebugInput():
	if Input.is_action_just_pressed("test_reload_scene"):
		get_tree().reload_current_scene()
		local_init()
		global_init()
		
	if Input.is_action_just_pressed("global_reset"):
		print("GameState: global reset")
		local_init()
		global_init()
		
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
		
