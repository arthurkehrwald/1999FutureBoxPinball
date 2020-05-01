extends Node

func _ready():
	var node = $Node
	yield(get_tree().create_timer(3), "timeout")
	remove_child(node)
	var node2 = weakref($Node2)
	node2.get_ref().add_child(node)
	yield(get_tree().create_timer(3), "timeout")
	node2.get_ref().remove_child(node)
	add_child(node)
