extends Node

export var from_path : NodePath
export var to_path : NodePath

onready var from := get_node(from_path) as CanvasItem
onready var to := get_node(to_path) as CanvasItem

func _ready():
	from.connect("visibility_changed", self, "_on_from_visibility_changed")

func _on_from_visibility_changed():
	to.visible = from.visible
