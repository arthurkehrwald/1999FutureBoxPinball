extends Node

onready var spatial_node: Spatial = get_node("Node")

func _ready():
	printerr("lololo")
	spatial_node = get_node("Node")
	var pos = spatial_node.get_global_transform().origin
