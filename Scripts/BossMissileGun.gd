extends "res://Scripts/BossGun.gd"

export(bool) var missiles_ignore_gun_rotation = false

var missile_scene = preload("res://Scenes/Missile.tscn")

var missile_basis_node

func _ready():
	if missiles_ignore_gun_rotation and Globals.boss:
		missile_basis_node = Globals.boss
	else:
		missile_basis_node = muzzle


func shoot():
	$AudioStreamPlayer.play()
	var missile_instance = missile_scene.instance()
	var missile_parent = Spatial.new()
	var t = Transform(missile_basis_node.get_global_transform().basis,
			muzzle.get_global_transform().origin)
	missile_parent.set_global_transform(t)
	get_node("/root").add_child(missile_parent)
	missile_parent.add_child(missile_instance)
