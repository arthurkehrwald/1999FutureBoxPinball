extends "res://Scripts/Text3D.gd"

const FORMAT_STRING = "+$%sbn"

func set_money_amount(money_amount):
	set_text(FORMAT_STRING % round(money_amount))

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
