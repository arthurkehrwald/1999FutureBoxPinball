class_name EnemyFleet
extends Spatial

signal defeated

var total_ship_count = 0
var remaining_ship_count = 0
var is_active = false setget set_is_active

onready var ship_parent = get_node("ParentForAnimation")
onready var animation_player = get_node("AnimationPlayer")
onready var fly_in_audio_player = get_node("FlyInAudioPlayer")

func _ready():
	total_ship_count = ship_parent.get_child_count()
	remaining_ship_count = total_ship_count
	for ship in ship_parent.get_children():
		ship.connect("death", self, "_on_EnemyShip_death")
	set_is_active(false)


func set_is_active(value):
	is_active = value
	for ship in ship_parent.get_children():
		if value:
			ship.set_health(ship.MAX_HEALTH)
		ship.set_is_vulnerable(value)
	if animation_player.is_playing():
		animation_player.stop()
	if value:
		remaining_ship_count = total_ship_count
		animation_player.play("enemy_fleet_appear_anim")
		animation_player.queue("enemy_fleet_idle_anim")
		fly_in_audio_player.play()


func _on_EnemyShip_death():
	if is_active:
		remaining_ship_count -= 1
		if remaining_ship_count <= 0:
			set_is_active(false)
			emit_signal("defeated")
