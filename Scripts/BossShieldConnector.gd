class_name BossShieldConnector
extends Node

export var boss_path := NodePath()
onready var boss := get_node(boss_path) as Boss

export var shield_path := NodePath()
onready var shield := get_node(shield_path) as Shield

func _ready() -> void:
	boss.connect("is_vulnerable_changed", self, "_on_Boss_is_vulnerable_changed")

func _on_Boss_is_vulnerable_changed(value: bool) -> void:
	shield.set_health(shield.MAX_HEALTH)
	shield.set_is_vulnerable(value)
