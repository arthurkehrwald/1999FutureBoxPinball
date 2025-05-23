extends CanvasItem

export(int, "Mono", "Interlaced", "OverUnder", "LeftRight") var mode : int setget _set_mode
var mode_init := false
const MODE_COUNT := 4

export var left_viewport_path := NodePath() setget _set_left_viewport_path
var left_viewport_path_init := false
var left_viewport : Viewport setget _set_left_viewport
var left_viewport_init := false

export var right_viewport_path := NodePath() setget _set_right_viewport_path
var right_viewport_path_init := false
var right_viewport : Viewport setget _set_right_viewport
var right_viewport_init := false

export var video_viewport_path := NodePath()
onready var video_viewport := get_node(video_viewport_path) as Viewport
export var video_player_path:= NodePath()
onready var video_player := get_node(video_player_path) as VideoPlayer

func _ready():
	_set_left_viewport_path(left_viewport_path)
	_set_right_viewport_path(right_viewport_path)
	_set_mode(mode)
	video_player.connect("visibility_changed", self, "_on_video_player_visibility_changed")
	var video_tex = video_viewport.get_texture() if video_viewport != null else null
	material.set("shader_param/overlay", video_tex)

func _process(_delta):
	if (Input.is_action_just_pressed("cycle_stereo_mode")):
		_set_mode((mode + 1) % MODE_COUNT)

func _set_left_viewport_path(value: NodePath) -> void:
	if (left_viewport_path_init and value == left_viewport_path):
		return
	left_viewport_path = value
	var viewport = get_node(left_viewport_path) if has_node(left_viewport_path) else null
	if left_viewport_path == NodePath() or viewport != null:
		_set_left_viewport(get_node(left_viewport_path) as Viewport)

func _set_left_viewport(value: Viewport) -> void:
	if (left_viewport_init and value == left_viewport):
		return
	left_viewport = value
	var tex = left_viewport.get_texture() if left_viewport != null else null
	material.set("shader_param/left_camera", tex)
	left_viewport_init = true
	var path = left_viewport.get_path() if left_viewport != null else NodePath()
	_set_left_viewport_path(path)

func _set_right_viewport_path(value: NodePath) -> void:
	if (right_viewport_path_init and value == right_viewport_path):
		return
	right_viewport_path = value
	var viewport = get_node(right_viewport_path) if has_node(right_viewport_path) else null
	if right_viewport_path == NodePath() or viewport != null:
		_set_right_viewport(get_node(right_viewport_path) as Viewport)

func _set_right_viewport(value: Viewport) -> void:
	if (right_viewport_init and value == right_viewport):
		return
	right_viewport = value
	var tex = right_viewport.get_texture() if right_viewport != null else null
	material.set("shader_param/right_camera", tex)
	right_viewport_init = true
	var path = right_viewport.get_path() if right_viewport != null else NodePath()
	_set_right_viewport_path(path)

func _set_mode(value: int) -> void:
	if (mode_init and value == mode):
		return
	mode = value
	material.set("shader_param/mode", mode)
	mode_init = true

func _on_video_player_visibility_changed() -> void:
	material.set("shader_param/show_overlay", video_player.visible)
