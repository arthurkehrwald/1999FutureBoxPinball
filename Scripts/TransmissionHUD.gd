extends Control

export (String, FILE, "*.json") var transmissions_file_path : String

var transmissions_dict : Dictionary
var queued_transmission = ""

func _enter_tree():
	var file = File.new()
	assert(file.file_exists(transmissions_file_path))

	file.open(transmissions_file_path, file.READ)
	transmissions_dict = parse_json(file.get_as_text())
	assert (typeof(transmissions_dict) == TYPE_DICTIONARY and transmissions_dict.size() > 0)
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")	
	
func _on_GameState_stage_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.stage.PREGAME:
		transmission_panel_reset()
	match new_stage:
		GameState.stage.EXPOSITION:
			play_dialogue("exposition")
		GameState.stage.ENEMY_FLEET:
			play_dialogue("enemy_fleet_appears")
		
func play_dialogue(key):
	for transmission in transmissions_dict[key]:
		$Background/CharacterNameLabel.text = transmission["name"]
		$Background/TransmissionLabel.text = transmission["text"]
		$GlitchShader.glitch_out()
		yield(get_tree().create_timer(transmission["duration"]), "timeout")
	transmission_panel_reset()
	GameState.on_TransmissionHUD_finished()
	
func transmission_panel_reset():
	$Background/CharacterNameLabel.text = ""
	$Background/TransmissionLabel.text = ""
	$GlitchShader.glitch_out()
