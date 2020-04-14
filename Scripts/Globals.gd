extends Node

const PRICE_FOR_ALL_ITEMS_IN_SHOP = 200
const ROLLER_TOPSPEED = 20.0
const USELESS_COLLISION_WARNING_FORMAT_STRING = "%s registered a useless collision with %s. Check groups and collision masks."

var shop_menu = null
# shop - activate the menu, know price for items

var boss = null
# missile guns - shoot where boss is facing
# bomb guns - add and remove collision exceptions with bombs

var player_ship = null
# missiles - fly toward player
# shop menu - reduce money
# damageables & bumpers - add money
# shop entrance - open when player has enough money

var player_turret = null
# shop entrance - insert ball from inside shop entrance into turret

var trex = null
# transmission hud - play
