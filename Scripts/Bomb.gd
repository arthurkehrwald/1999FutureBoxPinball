extends "res://Scripts/Roller.gd"

const EXPLOSION_SCENE = preload("res://Scenes/Explosion.tscn")
const COLLISION_MASK_SWITCH_DELAY = .7

export var FUSE_TIME = 5.0

onready var explode_timer = get_node("ExplodeTimer")
onready var buildup_audio_timer = get_node("BuildupAudioTimer")
onready var buildup_audio_player = get_node("BuildupAudioPlayer")

func _ready():
	add_to_group("bombs")
	explode_timer.connect("timeout", self, "explode")
	explode_timer.start(FUSE_TIME)
	var buildup_audio_length = buildup_audio_player.stream.get_length()
	print(buildup_audio_length)
	if FUSE_TIME > buildup_audio_length:
		buildup_audio_timer.start(FUSE_TIME - buildup_audio_length)
		buildup_audio_timer.connect("timeout", buildup_audio_player, "play")
	else:
		buildup_audio_player.play()


func explode():
	var explosion_instance = EXPLOSION_SCENE.instance()
	explosion_instance.add_to_group("bomb_explosions")
	explosion_instance.set_transform(Transform(Basis.IDENTITY, get_transform().origin))
	get_parent().add_child(explosion_instance)
	PoolManager.request(PoolManager.BOMB_EXPLOSION, get_global_transform().origin)
	queue_free()


func on_Timer_timeout():
	explode()
