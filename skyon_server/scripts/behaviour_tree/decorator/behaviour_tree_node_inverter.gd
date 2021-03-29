class_name BehaviourTreeNodeDecoratorInverter
extends BehaviourTreeNodeDecorator



func _tick(data: Dictionary) -> int:
	var result = .get_child(0).tick(data)
	
	match result:
		BehaviourTreeResult.SUCCESS:
			return BehaviourTreeResult.FAILURE
		BehaviourTreeResult.FAILURE:
			return BehaviourTreeResult.SUCCESS
		_:
			return BehaviourTreeResult.RUNNING
