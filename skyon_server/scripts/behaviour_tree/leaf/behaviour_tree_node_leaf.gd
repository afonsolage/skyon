class_name BehaviourTreeNodeLeaf
extends BehaviourTreeNode

func _ready() -> void:
	if .get_child_count() != 0:
		Log.e("Behaviour tree node should not have children")
		

func _tick(_data: Dictionary) -> int:
	Log.e("You should not use this node!")
	return BehaviourTreeResult.SUCCESS
