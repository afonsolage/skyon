class_name MainPlayerPortrait
extends Control

var _max_foreground_size : float

onready var _health_bar: Sprite = $health_bar

func _ready() -> void:
	_max_foreground_size = _health_bar.region_rect.size.x

	
func update_health(health: int, max_health: int) -> void:
	var rate := float(health) / float(max_health)
	_health_bar.region_rect.size.x = rate * _max_foreground_size
	_health_bar.offset.x = (_health_bar.region_rect.size.x - _max_foreground_size) / 2.0
	pass
