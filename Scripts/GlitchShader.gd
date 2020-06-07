extends Control

export var auto_glitch = false
export var auto_glitch_rate = 3.0

var rng = RandomNumberGenerator.new()

onready var super_glitch_timer = get_node("SuperGlitchTimer")
onready var displacement_rect = get_node("displace")
onready var idle_animation_player = get_node("IdleAnimationPlayer")
onready var super_glitch_animation_player = get_node("SuperGlitchAnimationPlayer")

func _ready():
	super_glitch_timer.connect("timeout", self, "on_SuperGlitchTimer_timeout")
	#make displacement color rect material unique so that instances can be animated separately
	var unique_material = displacement_rect.get_material().duplicate()
	displacement_rect.set_material(unique_material)
	idle_animation_player.play("glitch_idle")
	if auto_glitch:
		rng.randomize()
		super_glitch_timer.start(rng.randf_range(auto_glitch_rate * .8, auto_glitch_rate * 1.2))


func super_glitch():
	super_glitch_animation_player.play("super_glitch")


func on_SuperGlitchTimer_timeout():
	super_glitch()
	super_glitch_timer.start(rng.randf_range(auto_glitch_rate * .8, auto_glitch_rate * 1.2))


