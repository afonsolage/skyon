class_name BTreeNodeLeaf
extends BTreeNode

func _ready() -> void:
	if .get_child_count() != 0:
		Log.e("Behaviour tree node should not have children")
		

func _tick(_data: Dictionary) -> int:
	Log.e("You should not use this node!")
	return BTreeResult.SUCCESS
