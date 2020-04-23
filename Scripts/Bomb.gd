extends "res://Scripts/Roller.gd"

const EXPLOSION_SCENE = preload("res://Scenes/Explosion.tscn")
const COLLISION_MASK_SWITCH_DELAY = .7

export var FUSE_TIME = 5.0

onready var timer = get_node("Timer")


func _ready():
	add_to_group("bombs")
	timer.connect("timeout", self, "on_Timer_timeout")
	timer.start(FUSE_TIME)


func explode():
	var explosion_instance = EXPLOSION_SCENE.instance()
	explosion_instance.add_to_group("bomb_explosions")
	explosion_instance.set_transform(Transform(Basis.IDENTITY, get_transform().origin))
	get_parent().add_child(explosion_instance)
	queue_free()


func on_Timer_timeout():
	explode()
