extends "res://Scripts/BossGun.gd"

var missile_scene = preload("res://Scenes/Missile.tscn")
var missile_animation_format_string = "missile_animation_0%s"

var rng = RandomNumberGenerator.new()

func _ready():
		rng.randomize()

func _shoot():
	var animation_index = rng.randi_range(1,3)
	$AudioStreamPlayer.play()
	var missile_instance = missile_scene.instance()
	missile_instance.set_transform($Muzzle.get_transform())
	$Muzzle.add_child(missile_instance)
	missile_instance.get_node("AnimationPlayer").play(missile_animation_format_string % animation_index)
