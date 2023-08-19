extends Area

var rng = RandomNumberGenerator.new()

onready var audio_player = get_node("AudioStreamPlayer")
onready var fx = get_node("StarGateFX")

func _ready():
	if Globals.teleporter_exits.empty():
		push_warning("[TeleporterEntrance] can't find any exits. Will not work.")
		return
	rng.randomize()
	set_is_active(true)
	connect("body_entered", self, "on_body_entered")


func set_is_active(value):
	set_deferred("monitoring", value)
	fx.set_is_emitting(value)


func on_body_entered(body):
	if not body.is_in_group("rollers"):
		return
	audio_player.play()
	var exit_index = rng.randi_range(0, Globals.teleporter_exits.size() - 1)
	var exit = Globals.teleporter_exits[exit_index]
	body.teleport(exit.get_global_transform().origin)
	body.set_linear_velocity(Vector3(0, 0, 0))
	PoolManager.request(PoolManager.STAR_GATE_ENTER, body.get_global_transform().origin)
	PoolManager.request(PoolManager.STAR_GATE_EXIT, exit.get_global_transform().origin)
