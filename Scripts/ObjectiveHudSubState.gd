class_name ObjectiveHudSubState
extends "res://Scripts/State.gd"

export var path_to_animation_player := NodePath()
export var path_to_objective_checkbox := NodePath()
export var path_to_message_label := NodePath()

onready var animation_player := get_node(path_to_animation_player) as AnimationPlayer
onready var objective_checkbox := get_node(path_to_objective_checkbox) as CheckBox
onready var message_label := get_node(path_to_message_label) as Label
