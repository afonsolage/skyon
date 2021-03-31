class_name BTreeNodeLeafActionDebugLog
extends BTreeNodeLeafAction

export(String) var message

func _tick(_data: Dictionary) -> int:
	Log.d(message)
	return ._success()
