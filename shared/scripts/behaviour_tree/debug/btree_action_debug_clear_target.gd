class_name BTreeNodeLeafActionDebugClearTarget
extends BTreeNodeLeafAction

func _tick(data: Dictionary) -> int:
	if not "debug" in data or not data.debug:
		return  _success()
	
	var target := _get_global(data, "debug_target_mesh") as Node
	if target and is_instance_valid(target):
		target.queue_free()
	
	_clear_global(data, "debug_target_mesh")
	
	return _success()
