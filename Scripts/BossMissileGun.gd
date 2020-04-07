extends "res://Scripts/BossGun.gd"

var missile_scene = preload("res://Scenes/Missile.tscn")

onready var missile_basis_node = _muzzle

func _ready():
	var parent = get_node_or_null("..")
	if parent != null and parent.name == "Boss":
		missile_basis_node = parent

func _shoot():
	$AudioStreamPlayer.play()
	var missile_instance = missile_scene.instance()
	var missile_parent = Spatial.new()
	var t = Transform(missile_basis_node.get_global_transform().basis, _muzzle.get_global_transform().origin)
	missile_parent.set_global_transform(t)
	get_node("/root").add_child(missile_parent)
	missile_parent.add_child(missile_instance)
