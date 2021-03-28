class_name FloatingText
extends Label

var follow_ref: WeakRef
var timeout: float = 1.0
var height_offset: float = 1.0
var _elapsed: float
var _origin: Vector3
var _timer: Timer

func _ready():
	if not follow_ref.get_ref():
		return
	
	_origin = follow_ref.get_ref().translation as Vector3
	_timer = Timer.new()
	add_child(_timer)
	Log.ok(_timer.connect("timeout", self, "_on_timer_timeout"))

func _process(delta: float) -> void:
	_elapsed += delta
	var screen_pos := _get_target_screen_position(delta)
	self.rect_position = screen_pos


func _get_target_screen_position(_delta: float) -> Vector2:
	var camera = Systems.world.get_camera()
	var node_pos = _origin
	node_pos.y += (_elapsed * 5) + height_offset
	return camera.unproject_position(node_pos)


func _on_timer_timeout() -> void:
	queue_free()
