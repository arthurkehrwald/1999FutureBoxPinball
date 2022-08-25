class_name TransmissionHud
extends Control

enum RexMood { NEUTRAL, INJURED, HAPPY, ANGRY }
enum SequenceId { EXPOSITION, ENEMY_FLEET, BOSSFIGHT}

export var INJURED_PORTRAIT_HEALTH_PERCENTAGE = 30.0
export var INJURED_REACTION_DURATION = 1.0
export (String, FILE, "*.json") var TRANSMISSIONS_FILE_PATH : String

const REX_PORTRAITS = {
	RexMood.NEUTRAL: preload("res://HUD/portrait_rex_neutral.png"),
	RexMood.INJURED: preload("res://HUD/portrait_rex_injured.png"),
	RexMood.HAPPY: preload("res://HUD/portrait_rex_happy.png"),
	RexMood.ANGRY: preload("res://HUD/portrait_rex_angry.png")	
}

const SEQ_NAMES = {
	SequenceId.EXPOSITION: "exposition",
	SequenceId.ENEMY_FLEET: "enemy_fleet_appears",
	SequenceId.BOSSFIGHT: "boss_appears"
}

const CAPTAIN_PORTRAIT = preload("res://HUD/portrait_captain.png")
const PORTRAIT_LOUIE = preload("res://HUD/portrait_louie.png")
const ENEMY_PORTRAIT = preload("res://HUD/portrait_enemy.png")
const EMPEROR_PORTRAIT = preload("res://HUD/portrait_emperor.png")
const TREX_PORTRAIT = preload("res://HUD/portrait_trex.png")
const GREEN_PANEL = preload("res://HUD/panel_left.png")
const RED_PANEL = preload("res://HUD/panel_left_red.png")

var sequences: Dictionary = {}
var queued_line = ""
var rex_mood = RexMood.NEUTRAL
var is_rex_on_display = true
var current_sequence_key = ""
var current_line_index = 0

onready var audio_player = get_node("AudioStreamPlayer")
onready var character_name_label = get_node("Background/CharacterNameLabel")
onready var portrait_rect = get_node("Background/PortraitRect")
onready var text_label = get_node("Background/TextLabel")
onready var glitch_overlay = get_node("../GlitchOverlay")
onready var transmission_timer = get_node("TransmissionTimer")
onready var hurt_reaction_timer = get_node("HurtReactionTimer")
onready var background_rect = get_node("Background")


func _ready():
	var file = File.new()
	assert(file.file_exists(TRANSMISSIONS_FILE_PATH))

	file.open(TRANSMISSIONS_FILE_PATH, file.READ)
	sequences = parse_json(file.get_as_text())
	assert (typeof(sequences) == TYPE_DICTIONARY and sequences.size() > 0)
	if Globals.player_ship != null:
		Globals.player_ship.connect("health_changed", self, "on_PlayerShip_health_changed")
	else:
		push_warning("[lineHUD]: can't find player! Will not adjust rex"
				+ " portrait based on health.")
	transmission_timer.connect("timeout", self, "on_TransmissionTimer_timeout")
	hurt_reaction_timer.connect("timeout", self, "on_HurtReactionTimer_timeout")
	for enemy_fleet in get_tree().get_nodes_in_group("enemy_fleets"):
		enemy_fleet = enemy_fleet as EnemyFleet
		if enemy_fleet:
			enemy_fleet.connect("is_active_changed", self, "_on_EnemyFleet_is_active_changed")
	if Globals.trex != null:
		Globals.trex.connect("death", self, "play_sequence", ["trex_defeated"])


func play_sequence(sequence_id: int):
	var key: String = SEQ_NAMES[sequence_id]
	display_line(key, 0)
	current_sequence_key = key
	current_line_index = 0
	transmission_timer.start(sequences[key][0]["duration"])


func display_line(key, index):
	var is_params_valid = sequences.has(key) and len(sequences[key]) > index
	assert(is_params_valid)
	if not is_params_valid:
		return
	var line = sequences[key][index]
	audio_player.play()
	character_name_label.text = line["name"]
	match line["name"]:
		"Rex":
			portrait_rect.texture = REX_PORTRAITS[rex_mood]
		"Capt'n Multiball":
			portrait_rect.texture = CAPTAIN_PORTRAIT
		"Enemies":
			portrait_rect.texture = ENEMY_PORTRAIT
		"Laser Trex":
			portrait_rect.texture = TREX_PORTRAIT
		"Emperor":
			portrait_rect.texture = EMPEROR_PORTRAIT
		_:
			portrait_rect.texture = null
			push_warning("[TransmissionHUD] Unknown character: '" + line["name"] + "'")
	is_rex_on_display = line["name"] == "Rex"
	text_label.text = line["text"]
	glitch_overlay.super_glitch()


func reset():
	character_name_label.text = ""
	text_label.text = ""
	portrait_rect.texture = REX_PORTRAITS[rex_mood]
	is_rex_on_display = true
	glitch_overlay.super_glitch()


func set_rex_mood(value):
	if rex_mood == value:
		return
	rex_mood = value
	if is_rex_on_display:
		portrait_rect.texture = REX_PORTRAITS[value]
		glitch_overlay.super_glitch()


func on_PlayerShip_health_changed(new_health, old_health, max_health):
	var is_hp_critical = new_health / max_health * 100 <= Globals.PLAYER_CRITICAL_HEALTH_PERCENT
	background_rect.texture = RED_PANEL if is_hp_critical else GREEN_PANEL
	if new_health < old_health:
		set_rex_mood(RexMood.INJURED)
		if is_hp_critical:
			hurt_reaction_timer.stop()
		else:
			hurt_reaction_timer.start(INJURED_REACTION_DURATION)
	elif not is_hp_critical:
		set_rex_mood(RexMood.NEUTRAL)


func on_TransmissionTimer_timeout():
	if current_line_index < sequences[current_sequence_key].size() - 1:
		current_line_index += 1
		display_line(current_sequence_key, current_line_index)
		transmission_timer.start(sequences[current_sequence_key][current_line_index]["duration"])
	else:
		reset()


func _on_EnemyFleet_is_active_changed(value: bool):
	if value:
		play_sequence(SequenceId.ENEMY_FLEET)
	


func on_HurtReactionTimer_timeout():
	set_rex_mood(RexMood.NEUTRAL)
