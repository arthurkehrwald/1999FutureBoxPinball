class_name GlitchOverlay
extends Control

export var auto_glitch = false
export var auto_glitch_rate = 3.0
export var effect_strength := 1.0 setget set_effect_strength

var rng = RandomNumberGenerator.new()

onready var super_glitch_timer = get_node("SuperGlitchTimer")
onready var displacement_rect := get_node("displace") as ColorRect
onready var idle_animation_player = get_node("IdleAnimationPlayer")
onready var super_glitch_animation_player = get_node("SuperGlitchAnimationPlayer")
# make displacement color rect material unique so that instances can be animated separately
onready var disp_mat := displacement_rect.material.duplicate() as ShaderMaterial
onready var shader_params := [
	ShaderParam.new("dispAmt", disp_mat),
	ShaderParam.new("dispSize", disp_mat),
	ShaderParam.new("abberationAmt", disp_mat),
]
onready var _is_ready := true

func _ready():
	super_glitch_timer.connect("timeout", self, "on_SuperGlitchTimer_timeout")
	displacement_rect.material = disp_mat
	idle_animation_player.play("glitch_idle")
	if auto_glitch:
		rng.randomize()
		super_glitch_timer.start(rng.randf_range(auto_glitch_rate * .8, auto_glitch_rate * 1.2))

func super_glitch():
	super_glitch_animation_player.play("super_glitch")

func on_SuperGlitchTimer_timeout():
	super_glitch()
	super_glitch_timer.start(rng.randf_range(auto_glitch_rate * .8, auto_glitch_rate * 1.2))

func set_effect_strength(value: float):
	effect_strength = value
	if not _is_ready:
		yield(self, "ready")
	for param in shader_params:
		param = param as ShaderParam
		param.set_mult(value)

class ShaderParam:
	var name: String
	var default_value
	var mat: ShaderMaterial
	
	func _init(_name: String, _material: ShaderMaterial):
		name = _name
		mat = _material
		default_value = mat.get_shader_param(name)
	
	func set_mult(value):
		mat.set_shader_param(name, default_value * value)
