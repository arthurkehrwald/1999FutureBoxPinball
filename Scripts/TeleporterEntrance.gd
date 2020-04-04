extends Area

export var exit_1_chance = .4
export var exit_2_chance = .8

var current_exit_1_chance = 0
var current_exit_2_chance = 0

signal ball_entered_1(ball, teleporter_entrance)
signal ball_entered_2(ball, teleporter_entrance)
signal ball_entered_3(ball, teleporter_entrance)

var rng = RandomNumberGenerator.new()

func _ready():
	current_exit_1_chance = exit_1_chance
	current_exit_2_chance = exit_2_chance
	rng.randomize()

func set_is_active(is_active):
	$CollisionShape.set_deferred("disabled", !is_active)

func _on_TeleporterEntrance_body_entered(body):
	$AudioStreamPlayer.play()
	var random = randf()
	if random < exit_1_chance:
		emit_signal("ball_entered_1", body)
	elif random < exit_2_chance or body.is_in_group("Bombs"):
		emit_signal("ball_entered_2", body)
	else:
		emit_signal("ball_entered_3", body)

func set_turret_exit_enabled(var enable):
	if enable:
		current_exit_1_chance = exit_1_chance
		current_exit_2_chance = exit_2_chance
	else:
		current_exit_1_chance += (1 - current_exit_2_chance) / 2
		current_exit_2_chance += (1 - current_exit_2_chance) / 2
