extends Sprite3D

signal finished

const FORMAT_STRING = "+$%sbn"

onready var viewport = get_node("Viewport")
onready var label = get_node("Viewport/Label")
onready var animation_player = get_node("AnimationPlayer")


func _ready():
	texture = viewport.get_texture()
	animation_player.connect("animation_finished", self, "on_animation_finished")


func activate():
	animation_player.play("score_text_3d_fade_anim")


func set_money_amount(money_amount):
	label.text = FORMAT_STRING % round(money_amount)


func on_animation_finished(_anim_name):
	emit_signal("finished")
