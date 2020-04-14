extends Spatial

export var APPEAR_DURATION = 3.0
export var EXPAND_DURATION = 10.0
export var FADE_DURATION = 1.0

onready var rng = RandomNumberGenerator.new()
onready var mesh = get_node("PullArea/MeshInstance")
onready var base_scale_vector = mesh.get_transform().basis.get_scale()
onready var current_scale_vector = base_scale_vector
onready var animation_player = get_node("AnimationPlayer")
onready var pull_area = get_node("PullArea")
onready var nom_area = get_node("PullArea/NomArea")
var scale_interp_value = 1


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")
	nom_area.connect("body_entered", self, "on_NomArea_body_entered")
	base_scale_vector = mesh.get_transform().basis.get_scale()
	current_scale_vector = base_scale_vector
	rng.randomize()


func _process(_delta):
	if animation_player.is_playing():
		current_scale_vector = mesh.get_transform().basis.get_scale()
	mesh.set_transform(Transform.IDENTITY.scaled(current_scale_vector * rng.randfn(1, .1)))


func on_GameState_changed(new_state, is_debug_skip):
	if new_state == GameState.BLACK_HOLE:
		Announcer.say("black_hoe", true)
		animation_player.play("black_hole_appear_anim", -1, 1 / APPEAR_DURATION)
		set_is_active(true)
	elif new_state == GameState.ECLIPSE: 
		if is_debug_skip:
			set_is_active(true)
		expand()
	elif is_debug_skip or new_state == GameState.PREGAME:
		set_is_active(false)


func on_NomArea_body_entered(body):
	if not body.is_in_group("projectiles"):
		return
	body.bid_farewell()
	body.queue_free()


func set_is_active(value):
	set_visible(value)
	set_process(value)
	pull_area.set_deferred("monitoring", value)
	nom_area.set_deferred("monitoring", value)


func expand():
	set_process(false)
	animation_player.play("black_hole_expand_anim", -1, 1 / EXPAND_DURATION)
	
	yield(animation_player, "animation_finished")
	
	GameState.handle_event(GameState.Event.BLACK_HOLE_EXPANDED)
	fade()


func fade():
	animation_player.play("black_hole_fade", -1, 1 / FADE_DURATION)
	
	yield(animation_player, "animation_finished")
	
	set_is_active(false)
