class_name BossBar3D
extends "res://Scripts/ViewportTextureSetter.gd"


func _on_Boss_health_changed(health, old_health, max_health):
	$Viewport/BossBar/HealthBar.update_value(health, old_health, max_health)


func _on_Shield_is_vulnerable_changed(value):
	$Viewport/BossBar/ShieldBar.visible = value


func _on_Shield_health_changed(health, old_health, max_health):
	$Viewport/BossBar/ShieldBar.update_value(health, old_health, max_health)


func _on_Boss_is_active_changed(value):
	$Viewport/BossBar.visible = value
