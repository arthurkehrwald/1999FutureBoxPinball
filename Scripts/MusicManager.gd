class_name MusicManager
extends Node

export var path_to_music_player_1 := NodePath()
export var path_to_music_player_2 := NodePath()

onready var on_player := get_node(path_to_music_player_1) as MusicTrackPlayer
onready var off_player := get_node(path_to_music_player_2) as MusicTrackPlayer

func _ready():
	for music_component in get_tree().get_nodes_in_group("music_component"):
		music_component = music_component as MusicComponent
		music_component.connect("is_active_changed", self, "_on_MusicComponent_is_active_changed", [music_component])


func _on_MusicComponent_is_active_changed(value: bool, music_component: MusicComponent):
	if value:
		if music_component.stream:
			var tmp := off_player
			off_player = on_player
			on_player = tmp
			off_player.stop_playing()
			on_player.stream = music_component.stream
			on_player.start_playing()
		else:
			on_player.stop_playing()
