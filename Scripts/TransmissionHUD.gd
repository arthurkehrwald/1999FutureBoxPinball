extends Control

export (String, FILE, "*.json") var transmissions_file_path : String
var portrait_rex_neutral = preload("res://HUD/portrait_rex_neutral.png")
var portrait_rex_injured = preload("res://HUD/portrait_rex_injured.png")
var portrait_rex_defeat = preload("res://HUD/portrait_rex_defeat.png")
var portrait_rex_victory = preload("res://HUD/portrait_rex_victory.png")
var portrait_captain = preload("res://HUD/portrait_captain.png")
var portrait_louie = preload("res://HUD/portrait_louie.png")
var portrait_enemy = preload("res://HUD/portrait_enemy.png")
var portrait_emperor = preload("res://HUD/portrait_emperor.png")
var portrait_laser_trex = preload("res://HUD/portrait_trex.png")

var transmissions_dict : Dictionary
var queued_transmission = ""
enum rex_portrait {NEUTRAL, INJURED, DEFEAT, VICTORY}
var current_rex_portrait 
var is_rex_on_display = true

func _enter_tree():
	var file = File.new()
	assert(file.file_exists(transmissions_file_path))

	file.open(transmissions_file_path, file.READ)
	transmissions_dict = parse_json(file.get_as_text())
	assert (typeof(transmissions_dict) == TYPE_DICTIONARY and transmissions_dict.size() > 0)
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")	
	GameState.connect("defeat", self, "set_current_rex_portrait", [rex_portrait.DEFEAT])
	GameState.connect("victory", self, "set_current_rex_portrait", [rex_portrait.VICTORY])
	

func _on_GameState_stage_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.stage.PREGAME:
		set_current_rex_portrait(rex_portrait.NEUTRAL)
		transmission_panel_reset()
	match new_stage:
		GameState.stage.EXPOSITION:
			play_dialogue("exposition")
		GameState.stage.ENEMY_FLEET:
			play_dialogue("enemy_fleet_appears")
		
func play_dialogue(key):
	for transmission in transmissions_dict[key]:
		$AudioStreamPlayer.play()
		$Background/CharacterNameLabel.text = transmission["name"]
		is_rex_on_display = false
		match transmission["name"]:
			"Rex":
				$Background/PortraitRect.texture = current_rex_portrait
				is_rex_on_display = true
			"Cap'n Multiball":
				$Background/PortraitRect.texture = portrait_captain
			"Enemies":
				$Background/PortraitRect.texture = portrait_enemy
			"LaZer Trex":
				$Background/PortraitRect.texture = portrait_laser_trex
			"Emperor":
				$Background/PortraitRect.texture = portrait_emperor
		$Background/TransmissionLabel.text = transmission["text"]
		$Background/GlitchShader.glitch_out()
		yield(get_tree().create_timer(transmission["duration"]), "timeout")
	transmission_panel_reset()
	GameState.on_TransmissionHUD_finished()
	
func transmission_panel_reset():
	$Background/CharacterNameLabel.text = ""
	$Background/TransmissionLabel.text = ""
	$Background/PortraitRect.texture = current_rex_portrait
	is_rex_on_display = true
	$Background/GlitchShader.glitch_out()
	
func set_current_rex_portrait(portrait_type):
	match portrait_type:
		rex_portrait.NEUTRAL:
			current_rex_portrait = portrait_rex_neutral
		rex_portrait.INJURED:
			current_rex_portrait = portrait_rex_injured
		rex_portrait.DEFEAT:
			current_rex_portrait = portrait_rex_defeat
		rex_portrait.VICTORY:
			current_rex_portrait = portrait_rex_victory
	if is_rex_on_display:
		$Background/PortraitRect.texture = current_rex_portrait
		$Background/GlitchShader.glitch_out()


func _on_PlayerShip_health_changed(new_health, max_health, old_health):
	if old_health / max_health > .2:
		if new_health / max_health < .2:
			set_current_rex_portrait(rex_portrait.INJURED)
	else:
		if new_health / max_health > .2:
			set_current_rex_portrait(rex_portrait.NEUTRAL)
