class_name BTreeNodeLeafActionDebugClearTarget
extends BTreeNodeLeafAction

func _tick(data: Dictionary) -> int:
	var target := _get_global(data, "debug_target_mesh") as Node
	if not target:
		Log.e("Not debug target mesh found!")
		return _failure()
	
	target.queue_free()
	
	return _success()
