class_name BehaviourTreeNodeDecoratorLimiter
extends BehaviourTreeNodeDecorator

export(int) var max_count = -1

func _tick(data: Dictionary) -> int:
	var count = _restore(data, "count") as int
	
	if not count:
		count = 0
	
	if count <= max_count:
		_store(data, "count", count + 1)
		return .get_child(0).tick(data)
	else:
		return BehaviourTreeResult.FAILURE
