class_name State
extends Node
# Encapsulates state specific behaviour of the node it belongs to and handles
# transitions to other states.

onready var _state_machine = get_node("..")


func _enter(var _info = {}):
	pass


func _handle_input(var _input, _info = {}):
	pass


func _exit():
	pass
