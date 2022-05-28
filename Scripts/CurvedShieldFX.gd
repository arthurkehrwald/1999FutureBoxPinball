extends MeshInstance

export var FADE_TIME = 1.0

var fade_progress = 0
var is_shield_vulnerable = false

func _ready():
	get_surface_material(0).set_shader_param("FadeProgress", 2.5)
	
	
func _process(delta):
	if is_shield_vulnerable and fade_progress < 1:
		set_fade_progress(fade_progress + FADE_TIME * delta)
	elif not is_shield_vulnerable and fade_progress > 0:
		set_fade_progress(fade_progress - FADE_TIME * delta)


func set_fade_progress(value : float):
	get_surface_material(0).set_shader_param("FadeProgress", value * 1.5 + 2.5)
	visible = fade_progress > 0


func _on_CurvedShield_is_vulnerable_changed(value):
	is_shield_vulnerable = value
