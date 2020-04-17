extends Area

var rng = RandomNumberGenerator.new()

onready var audio_player = get_node("AudioStreamPlayer")

func _ready():
	if Globals.teleporter_exits.empty():
		push_warning("[TeleporterEntrance] can't find any exits. Will not work.")
		return
	rng.randomize()
	GameState.connect("state_changed", self, "on_GameState_changed")
	connect("body_entered", self, "on_body_entered")


func set_is_active(value):
	set_deferred("monitoring", value)


func on_body_entered(body):
	if not body.is_in_group("rollers"):
		return
	audio_player.play()
	var exit_index = rng.randi_range(0, Globals.teleporter_exits.size() - 1)
	var exit = Globals.teleporter_exits[exit_index]
	var exit_dir = -exit.get_global_transform().basis.z
	body.teleport(exit.get_global_transform().origin)
	body.set_linear_velocity(exit_dir * body.get_linear_velocity().length())


func on_GameState_changed(new_state, _is_debug_skip):
	var is_bossfight = new_state > GameState.ENEMY_FLEET and new_state < GameState.VICTORY
	set_is_active(new_state == GameState.TESTING or is_bossfight)
		
