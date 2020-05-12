extends Node

const ROLLER_TOPSPEED = 40.0

var shop_menu = null
# shop - activate the menu, know price for items
# player turret - enter firing mode when the player buys a turret shot

var powerup_roulette = null

var boss = null
# missile guns - shoot where boss is facing
# bomb guns - add and remove collision exceptions with bombs

var player_ship = null
# missiles - fly toward player
# shop menu - reduce money
# damageables & bumpers - add money
# shop entrance - open when player has enough money
# transmission hud - display injured rex portrait when health is low
# player stats hud - display health, coolness and money
# looping louie - maximise coolness
# flippers - forward explosion and missile impacts to player 

var trex = null
# transmission hud - play

var teleporter_exits = []
# stargate - teleport ball there

var head_track_cam_dummy = null
# weird camera - interpret head tracking input

var player_turret = null
# roulette + ball spawn - insert pinballs

var moon_shop = null
# player stats hud - display progress to opening
