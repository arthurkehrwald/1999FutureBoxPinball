extends Node

const PRICE_FOR_ALL_ITEMS_IN_SHOP = 200
const ROLLER_TOPSPEED = 20.0
const USELESS_COLLISION_WARNING_FORMAT_STRING = "%s registered a useless collision with %s. Check groups and collision masks."

var shop_menu = null
var boss = null
var player = null
