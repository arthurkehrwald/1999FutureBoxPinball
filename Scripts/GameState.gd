extends Node

# Balancing variables---------------------
const START_PLAYER_HEALTH = 100
const MAX_PLAYER_HEALTH = 100
const START_PLAYER_MONEY = 200
const MAX_PLAYER_MONEY = 1000
const BALL_DRAINED_PLAYER_DAMAGE = 25
const START_BOSS_HEALTH = 50
const MAX_BOSS_HEALTH = 100
#-----------------------------------------

signal global_reset
signal reset_ball
signal game_over
signal boss_died
signal player_died
signal boss_health_changed(new_boss_health)
signal player_health_changed(new_player_health)
signal player_money_changed(new_player_money)
signal player_money_maxed

signal set_wireframe_material( material)
signal set_collision_object_material(material)
signal toggle_nightmode(toggle)

var player_money = 100 setget set_player_money
var boss_health = 100 setget set_boss_health
var player_health = 100 setget set_player_health
var nightmode_enabled = false

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
	emit_signal("set_wireframe_material", pink_unlit)
	emit_signal("set_collision_object_material", light_blue)
	emit_signal("toggle_nightmode", true)
	emit_signal("global_reset")
	nightmode_enabled = true
	
func local_init():
	set_player_health(START_PLAYER_HEALTH)
	set_player_money(START_PLAYER_MONEY)
	set_boss_health(START_BOSS_HEALTH)	

func _on_PlayerShip_ball_drained():
	set_player_health(player_health - BALL_DRAINED_PLAYER_DAMAGE)
	if player_health > 0:
		print("GameState: ball drained reset")
		emit_signal("reset_ball")
	else:
		emit_signal("game_over")
		
func set_boss_health(new_boss_health):
	boss_health = clamp(new_boss_health, 0, MAX_BOSS_HEALTH)
	emit_signal("boss_health_changed", boss_health)
	if boss_health == 0:
		emit_signal("boss_died")

func set_player_health(new_player_health):
	player_health = clamp(new_player_health, 0, MAX_PLAYER_HEALTH)
	emit_signal("player_health_changed", player_health)
	if player_health == 0:
		emit_signal("player_died")
	
func set_player_money(new_player_money):
	player_money = clamp(new_player_money, 0, MAX_PLAYER_MONEY)
	emit_signal("player_money_changed", player_money)
	if player_money == MAX_PLAYER_MONEY:
		emit_signal("player_money_maxed")
		
func _on_MultiballShip_ball_locked():
	pass

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
		
