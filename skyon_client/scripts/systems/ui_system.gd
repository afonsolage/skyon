class_name UISystem
extends Node

onready var _main_player_portrait: MainPlayerPortrait = $MainPlayerPortrait


func _on_PlayerSystem_health_changed(health, max_health):
	_main_player_portrait.update_health(health, max_health)
