class_name BTreeNodeDecoratorInverter
extends BTreeNodeDecorator



func _tick(data: Dictionary) -> int:
	var result = .get_child(0)._tick(data)
	
	match result:
		BTreeResult.SUCCESS:
			return BTreeResult.FAILURE
		BTreeResult.FAILURE:
			return BTreeResult.SUCCESS
		_:
			return BTreeResult.RUNNING
