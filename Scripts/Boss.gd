extends StaticBody

export var ball_damage_taken_multiplier = 1.0
export var bomb_fire_rate = 10
export var bomb_muzzle_velocity = 10
export var missile_fire_rate = 5

onready var bomb_scene = preload("res://Scenes/Bomb.tscn")
onready var missile_scene = preload("res://Scenes/Missile.tscn")
var missile_animation_format_string = "missile_animation_0%s"

var rng = RandomNumberGenerator.new()

func _ready():
	$BombShootTimer.wait_time = bomb_fire_rate
	$MissileShootTimer.wait_time = missile_fire_rate
	rng.randomize()

func _process(_delta):
	if Input.is_action_just_pressed("boss_fire_three_missiles"):
		fire_three_missiles()

func _on_HitboxArea_body_entered(body):
	if body.name == "Ball":
		var damage = body.get_linear_velocity().length() * ball_damage_taken_multiplier
		GameState.set_boss_health(GameState.boss_health - damage)


func _on_BombShootTimer_timeout():
	var bomb_instance = bomb_scene.instance()
	bomb_instance.set_transform($RightMuzzle.get_transform())
	add_child(bomb_instance)
	bomb_instance.apply_central_impulse(-bomb_instance.get_global_transform().basis.z.normalized() * bomb_muzzle_velocity)


func _on_MissileShootTimer_timeout():
	fire_missile(rng.randi_range(1,3))
	
func fire_missile(animation_index):
	var missile_instance = missile_scene.instance()
	missile_instance.set_transform($RightMuzzle.get_transform())
	$MissileMuzzle.add_child(missile_instance)
	missile_instance.get_node("AnimationPlayer").play(missile_animation_format_string % animation_index)
		
func fire_three_missiles():
	fire_missile(1)
	$MissileBurstTimer.start()
	yield($MissileBurstTimer, "timeout")
	fire_missile(2)
	$MissileBurstTimer.start()
	yield($MissileBurstTimer, "timeout")
	fire_missile(3)
	$MissileBurstTimer.stop()
