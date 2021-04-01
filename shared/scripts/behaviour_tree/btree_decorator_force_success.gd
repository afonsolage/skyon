class_name BTreeNodeDecoratorForceSuccess
extends BTreeNodeDecorator


func _tick(data: Dictionary) -> int:
	var result = .get_child(0)._tick(data)
	
	if result == BTreeResult.RUNNING:
		return result
	else:
		return _success()
