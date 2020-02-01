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
	print(transmissions_dict.size())
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	GameState.connect("exposition_began", self, "play_dialogue", ["exposition"])
	GameState.connect("enemy_fleet_fight_began", self, "play_dialogue", ["enemy_fleet_appears"])
	
func _on_GameState_global_reset(_is_init):
	transmission_panel_reset()
		
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
