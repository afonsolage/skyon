class_name BehaviourTreeNodeCompositeSequence
extends BehaviourTreeNodeComposite

func _tick(data: Dictionary) -> int:
	for child in .get_children():
		var result = child.tick(data)
		
		if result != BehaviourTreeResult.SUCCESS:
			return result
	
	return BehaviourTreeResult.SUCCESS
