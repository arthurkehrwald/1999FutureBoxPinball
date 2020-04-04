extends Control

enum RexMood {NEUTRAL, INJURED, HAPPY, ANGRY}

export var INJURED_PORTRAIT_HEALTH_PERCENTAGE = 0.3
export (String, FILE, "*.json") var TRANSMISSIONS_FILE_PATH : String

const REX_PORTRAITS = {
	RexMood.NEUTRAL: preload("res://HUD/portrait_rex_neutral.png"),
	RexMood.INJURED: preload("res://HUD/portrait_rex_injured.png"),
	RexMood.HAPPY: preload("res://HUD/portrait_rex_happy.png"),
	RexMood.ANGRY: preload("res://HUD/portrait_rex_angry.png")	
}
const CAPTAIN_PORTRAIT = preload("res://HUD/portrait_captain.png")
const PORTRAIT_LOUIE = preload("res://HUD/portrait_louie.png")
const ENEMY_PORTRAIT = preload("res://HUD/portrait_enemy.png")
const EMPEROR_PORTRAIT = preload("res://HUD/portrait_emperor.png")
const TREX_PORTRAIT = preload("res://HUD/portrait_trex.png")

var _transmissions : Dictionary
var _queued_transmission = ""
var _rex_mood = RexMood.NEUTRAL
var _is_rex_on_display = true


func _enter_tree():
	var file = File.new()
	assert(file.file_exists(TRANSMISSIONS_FILE_PATH))

	file.open(TRANSMISSIONS_FILE_PATH, file.READ)
	_transmissions = parse_json(file.get_as_text())
	assert (typeof(_transmissions) == TYPE_DICTIONARY and _transmissions.size() > 0)
	GameState.connect("state_changed", self, "_on_GameState_changed")	
	

func _on_GameState_changed(new_state, is_debug_skip):
	if is_debug_skip or new_state == GameState.PREGAME:
		_set_rex_mood(RexMood.NEUTRAL)
		transmission_panel_reset()
	match new_state:
		GameState.EXPOSITION:
			play_dialogue("exposition")
		GameState.ENEMY_FLEET:
			play_dialogue("enemy_fleet_appears")
		GameState.VICTORY:
			_set_rex_mood(RexMood.HAPPY)
		GameState.DEFEAT:
			_set_rex_mood(RexMood.ANGRY)


func play_dialogue(key):
	for transmission in _transmissions[key]:
		$AudioStreamPlayer.play()
		$Background/CharacterNameLabel.text = transmission["name"]
		_is_rex_on_display = false
		match transmission["name"]:
			"Rex":
				$Background/PortraitRect.texture = REX_PORTRAITS[_rex_mood]
				_is_rex_on_display = true
			"Cap'n Multiball":
				$Background/PortraitRect.texture = CAPTAIN_PORTRAIT
			"Enemies":
				$Background/PortraitRect.texture = ENEMY_PORTRAIT
			"LaZer Trex":
				$Background/PortraitRect.texture = TREX_PORTRAIT
			"Emperor":
				$Background/PortraitRect.texture = EMPEROR_PORTRAIT
		$Background/TransmissionLabel.text = transmission["text"]
		$Background/GlitchShader.glitch_out()
		yield(get_tree().create_timer(transmission["duration"]), "timeout")
	transmission_panel_reset()
	GameState.handle_event(GameState.Event.TRANSMISSION_FINISHED)


func transmission_panel_reset():
	$Background/CharacterNameLabel.text = ""
	$Background/TransmissionLabel.text = ""
	$Background/PortraitRect.texture = REX_PORTRAITS[_rex_mood]
	_is_rex_on_display = true
	$Background/GlitchShader.glitch_out()


func _set_rex_mood(value):
	_rex_mood = value
	if _is_rex_on_display:
		$Background/PortraitRect.texture = REX_PORTRAITS[value]
		$Background/GlitchShader.glitch_out()


func _on_PlayerShip_health_changed(new_health, max_health, old_health):
	if old_health / max_health > INJURED_PORTRAIT_HEALTH_PERCENTAGE:
		if new_health / max_health < INJURED_PORTRAIT_HEALTH_PERCENTAGE:
			_set_rex_mood(RexMood.INJURED)
	else:
		if new_health / max_health > INJURED_PORTRAIT_HEALTH_PERCENTAGE:
			_set_rex_mood(RexMood.NEUTRAL)
