extends "res://Scripts/Projectile.gd"

const EXPLOSION_SCENE = preload("res://Scenes/MissileExplosion.tscn")

export var SPEED = 1.0
export var STEERABILITY = 1.0

onready var _animation_player = get_node("AnimationPlayer")

func _ready():
	_animation_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	_animation_player.play("missile_launch", -1, SPEED)


func _explode():
	var explosion_instance = EXPLOSION_SCENE.instance()
	explosion_instance.set_transform(Transform(Basis.IDENTITY, get_transform().origin))
	get_parent().add_child(explosion_instance)
	queue_free()


func _on_HitregArea_area_entered(area):
	if area.has_method("on_hit_by_bomb_directly"):
		area.on_hit_by_bomb_directly(get_global_transform().origin,
				get_linear_velocity())


func _on_HitregArea_body_entered(body):
	if body.has_method("on_hit_by_bomb_directly"):
		body.on_hit_by_bomb_directly(get_global_transform().origin,
				get_linear_velocity())
	_explode()


func _on_AnimationPlayer_animation_finished(_animation_name):
	mode = RigidBody.MODE_RIGID
	add_force(Vector3(0, 0, -SPEED * 80), Vector3(0, 0, .5))
