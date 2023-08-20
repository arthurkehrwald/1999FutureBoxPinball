extends Node

const ONE_GAME_UNIT_IN_METERS = .044375
const ROLLER_TOPSPEED = 40.0
const PLAYER_CRITICAL_HEALTH_PERCENT = 30.0
const CYAN_COLOR = Color(0, 1, .8, 1)
const RED_COLOR = Color(.97, .04, .40, 1)

var shop_menu = null
var powerup_roulette = null
var boss = null
var player_ship = null
var trex = null
var teleporter_exits = []
var head_track_cam_dummy = null
var player_turret = null
var moon_shop = null
var ball_spawn = null
var warning_hud = null
var screen_center_child = null
var highscore_tracker: HighscoreTracker = null
