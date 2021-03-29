class_name BTreeNodeComposite
extends BTreeNode

func _ready() -> void:
	if .get_child_count() < 1:
		Log.e("Behaviour tree node composite should have at least 1 child")


func _tick(_data: Dictionary) -> int:
	Log.e("You should not use this node!")
	return _success()
