extends Node
tool

onready var parent_control = get_node("..") as Control

func _process(_delta):
	if parent_control:
		parent_control.rect_pivot_offset = parent_control.rect_size / 2
