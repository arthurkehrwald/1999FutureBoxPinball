extends Sprite

var sign_textures = []
var announcer_lines = []

var rng = RandomNumberGenerator.new()

func _enter_tree():
	GameState.connect("player_did_something", self, "show_sign")

func _ready():
	sign_textures.resize(12)
	announcer_lines.resize(12)
	sign_textures[0] = load("res://HUD/ribbon_beetlejuice.png")
	announcer_lines[0] = "beetlejuice"
	sign_textures[1] = load("res://HUD/ribbon_bitchin.png")
	announcer_lines[1] = "bitchin"
	sign_textures[2] = load("res://HUD/ribbon_bodacious.png")
	announcer_lines[2] = "bodacious"
	sign_textures[4] = load("res://HUD/ribbon_cheeah.png")
	announcer_lines[4] = "cheeah"
	sign_textures[10] = load("res://HUD/ribbon_dope.png")
	announcer_lines[10] = "dope"
	sign_textures[5] = load("res://HUD/ribbon_excellent.png")
	announcer_lines[5] = "excellent"
	sign_textures[6] = load("res://HUD/ribbon_fantabulous.png")
	announcer_lines[6] = "fantabulous"
	sign_textures[7] = load("res://HUD/ribbon_hype.png")
	announcer_lines[7] = "hype"
	sign_textures[8] = load("res://HUD/ribbon_juicy.png")
	announcer_lines[8] = "juicy"
	sign_textures[9] = load("res://HUD/ribbon_radical.png")
	announcer_lines[9] = "radical"
	sign_textures[3] = load("res://HUD/ribbon_righteous.png")
	announcer_lines[3] = "righteous"
	sign_textures[11] = load("res://HUD/ribbon_stellar.png")
	announcer_lines[11] = "stellar"
	set_visible(false)
	
func show_sign():
	if !$AnimationPlayer.is_playing():
		var random_index = rng.randi_range(0, sign_textures.size() - 1)
		texture = sign_textures[random_index]
		Announcer.say(announcer_lines[random_index])
		$AnimationPlayer.play("ribbon_anim")
		set_visible(true)
		yield($AnimationPlayer,"animation_finished")
		set_visible(false)
	
