class_name PowerupRouletteIcon
extends TextureRect
tool

signal selection_animation_finished

export(float) var min_scale := 0.5
export(float) var max_scale := 1.5
export(float, 0.0, 0.5) var fade_zone := 0.2
export(NodePath) var anim_player_path

var associated_powerup : Powerup setget set_associated_powerup
export var animation_progress : float setget set_animation_progress
var do_animate_scale : bool = true

onready var anim_player = get_node(anim_player_path) as AnimationPlayer
onready var unscaled_width := rect_size.x

func _ready():
	anim_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")


func _on_AnimationPlayer_animation_finished(_anim_name: String):
	do_animate_scale = true
	emit_signal("selection_animation_finished")


func _process(_delta):
	rect_size.x = rect_size.y
	rect_pivot_offset = Vector2.ONE * rect_size.x / 2.0


func set_associated_powerup(value: Powerup):
	associated_powerup = value
	texture = associated_powerup.icon


func set_animation_progress(value: float):
	value = clamp(value, 0.0, 1.0)
	animation_progress = value
	animate_x_pos(animation_progress)
	if do_animate_scale:
		animate_scale(animation_progress)
	animate_opacity()


func play_selection_animation():
	do_animate_scale = false
	anim_player.play("powerup_icon_scale_up")


func calc_dist_to_middle() -> float:
	return abs(animation_progress - 0.5)


func animate_x_pos(progress: float):
	var parent := get_parent() as Control
	if parent == null:
		return
	var min_pos_x = -rect_size.x
	var max_pos_x = parent.rect_size.x
	rect_position.x = lerp(min_pos_x, max_pos_x, progress)


func animate_scale(progress: float):
	var normalized_scale = -pow(abs(2 * progress - 1), 2) + 1
	rect_scale = lerp(Vector2.ONE * min_scale, Vector2.ONE * max_scale, normalized_scale)


func animate_opacity():
	var parent := get_parent() as Control
	if parent == null:
		return
	var max_vis_pos = parent.rect_size.x - rect_size.x
	var progress = clamp(rect_position.x / max_vis_pos, 0.0, 1.0)
	var normalized_opacity
	if progress > fade_zone and progress < 1 - fade_zone:
		normalized_opacity = 1
	else:
		var curve_offset = -fade_zone if progress < fade_zone else -1 + fade_zone
		normalized_opacity = -pow(abs(1 / fade_zone * (progress + curve_offset)), 2) + 1	
	modulate = lerp(Color(1, 1, 1, 0), Color(1, 1, 1, 1), normalized_opacity)
