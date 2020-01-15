extends "res://Scripts/BossGun.gd"

var missile_scene = preload("res://Scenes/Missile.tscn")
var missile_animation_format_string = "missile_animation_0%s"

var rng = RandomNumberGenerator.new()

export var missile_fire_rate = 5.0

func _ready():
		$ShotTimer.wait_time = missile_fire_rate
		$ShotTimer.start()
		rng.randomize()
		
func _process(_delta):
	if Input.is_action_just_pressed("boss_fire_three_missiles"):
		shoot_three_missiles()

func _on_ShotTimer_timeout():
	if !stunned:
		shoot_missile(rng.randi_range(1,3))

func shoot_missile(animation_index):
	print("missile")
	var missile_instance = missile_scene.instance()
	missile_instance.set_transform($Muzzle.get_transform())
	$Muzzle.add_child(missile_instance)
	missile_instance.get_node("AnimationPlayer").play(missile_animation_format_string % animation_index)

func shoot_three_missiles():
	shoot_missile(1)
	shoot_missile(2)
	shoot_missile(3)
