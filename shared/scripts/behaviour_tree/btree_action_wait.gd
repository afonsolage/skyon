class_name BTreeNodeLeafActionWait
extends BTreeNodeLeafAction

export(float) var min_seconds := 2
export(float) var max_seconds := 4

var _elapsed_time := 0.0
var _wait_seconds := 0.0

func _ready():
	_reset()

func _tick(data: Dictionary) -> int:
	var delta := data.delta as float
	
	_elapsed_time += delta
	
	if _elapsed_time > _wait_seconds:
		return _success()
	else:
		return _running()


func _reset() -> void:
	_elapsed_time = 0.0
	_wait_seconds = rand_range(min_seconds, max_seconds)
	._reset()
