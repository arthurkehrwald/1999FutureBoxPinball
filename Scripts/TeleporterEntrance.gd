extends Area

export var exit_1_chance = .4
export var exit_2_chance = .8

signal ball_entered_1(ball, teleporter_entrance)
signal ball_entered_2(ball, teleporter_entrance)
signal ball_entered_3(ball, teleporter_entrance)

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func set_active(is_active):
	$CollisionShape.set_deferred("disabled", !is_active)

func _on_TeleporterEntrance_body_entered(body):
	$AudioStreamPlayer.play()
	var random = randf()
	if random > exit_2_chance:
		emit_signal("ball_entered_1", body, self)
	elif random > exit_1_chance:
		emit_signal("ball_entered_2", body, self)
	else:
		emit_signal("ball_entered_3", body, self)
