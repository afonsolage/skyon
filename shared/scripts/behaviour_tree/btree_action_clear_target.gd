class_name BTreeNodeLeaftActionClearTarget
extends BTreeNodeLeafAction

func _tick(data: Dictionary) -> int:
	_set_global(data, "move_target", null)
	return _success()
