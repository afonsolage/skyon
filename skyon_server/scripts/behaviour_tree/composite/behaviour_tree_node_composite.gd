class_name BehaviourTreeNodeComposite
extends BehaviourTreeNode

func _ready() -> void:
	if .get_child_count() < 1:
		Log.e("Behaviour tree node composite should have at least 1 child")


func _tick(_data: Dictionary) -> int:
	Log.e("You should not use this node!")
	return BehaviourTreeResult.SUCCESS
