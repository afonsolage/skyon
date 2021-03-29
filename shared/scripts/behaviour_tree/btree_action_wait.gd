class_name BTreeNodeLeafActionWait
extends BTreeNodeLeafAction

export(float) var seconds:= 2

func _tick(data: Dictionary) -> int:
	var delta := data.delta as float
	var elapsed_time = _restore(data, "elapsed_time")
	
	if not elapsed_time:
		elapsed_time = 0
	
	elapsed_time += delta
	_store(data, "elapsed_time", elapsed_time)
	
	if elapsed_time > seconds:
		_reset(data)
		_set_global(data, "last_wait_timeout", OS.get_ticks_msec())
		return _success()
	else:
		return _running()

