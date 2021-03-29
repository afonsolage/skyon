class_name BehaviourTreeNodeCompositeSelector
extends BehaviourTreeNodeComposite

func _ready() -> void:
	if .get_child_count() < 1:
		Log.e("Behaviour tree node selector should have at least 1 child")

func _tick(data: Dictionary) -> int:
	for child in .get_children():
		var result = child.tick(data)
		
		if result != BehaviourTreeResult.FAILURE:
			return result
	
	return BehaviourTreeResult.FAILURE
