class_name PlayerShip
extends Spatial

export(NodePath) var PATH_TO_SHOP

onready var _shop_menu = Globals.shop_menu
onready var _damageable = get_node("Damageable")
onready var _audio_player = get_node("AudioStreamPlayer")


func _ready():
	GameState.player_ship = self
	_shop_menu.connect("bought_repair", self, "_on_ShopMenu_bought_repair")
	_damageable.connect("health_changed", self, "_on_Damageable_health_changed")
	_damageable.connect("death", GameState, "on_PlayerShip_death")


func _on_ShopMenu_bought_repair(var heal_percent):
	_damageable.heal(_damageable.MAX_HEALTH * .01 * heal_percent)


func _on_Damageable_health_changed(current_health, old_health, _max_health):
	if current_health < old_health:
		Announcer.say("ouch")
		_audio_player.play()
