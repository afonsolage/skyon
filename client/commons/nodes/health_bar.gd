extends Spatial

var health := 100 setget _set_health,_get_health
var max_health := 100 setget _set_max_health,_get_max_health

var _max_foreground_size : float

onready var _foreground := $Foreground

func _ready() -> void:
	_max_foreground_size = _foreground.region_rect.size.x


func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera()
	if not camera:
		return
	
	self.rotation_degrees = -self.get_parent_spatial().rotation_degrees


func _set_health(value: int) -> void:
	health = value
	_update_foreground()

func _get_health() -> int:
	return health


func _set_max_health(value: int) -> void:
	max_health = value
	_update_foreground()

func _get_max_health() -> int:
	return max_health


func _update_foreground() -> void:
	var rate := float(health) / float(max_health)
	_foreground.region_rect.size.x = rate * _max_foreground_size
	_foreground.offset.x = (_foreground.region_rect.size.x - _max_foreground_size) / 2.0


func reset() -> void:
	health = max_health
	_update_foreground()
