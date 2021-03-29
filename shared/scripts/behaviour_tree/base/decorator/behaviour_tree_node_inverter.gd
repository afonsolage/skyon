class_name BTreeNodeDecoratorInverter, "../icons/decorator.png"
extends BTreeNodeDecorator



func _tick(data: Dictionary) -> int:
	var result = .get_child(0).tick(data)
	
	match result:
		BTreeResult.SUCCESS:
			return BTreeResult.FAILURE
		BTreeResult.FAILURE:
			return BTreeResult.SUCCESS
		_:
			return BTreeResult.RUNNING
