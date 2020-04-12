extends "res://Scripts/BossGun.gd"

var missile_scene = preload("res://Scenes/Missile.tscn")

onready var missile_basis_node = muzzle

func _ready():
	if boss != null:
		missile_basis_node = boss


func shoot():
	$AudioStreamPlayer.play()
	var missile_instance = missile_scene.instance()
	var missile_parent = Spatial.new()
	var t = Transform(missile_basis_node.get_global_transform().basis,
			muzzle.get_global_transform().origin)
	missile_parent.set_global_transform(t)
	get_node("/root").add_child(missile_parent)
	missile_parent.add_child(missile_instance)
