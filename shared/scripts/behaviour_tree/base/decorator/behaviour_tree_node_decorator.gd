class_name BTreeNodeDecorator, "../icons/decorator.png"
extends BTreeNode

func _ready():
	if .get_child_count() != 1:
		Log.e("Behaviour tree node inverter should have only one child")


func _tick(_data: Dictionary) -> int:
	Log.e("You should not use this node!")
	return BTreeResult.SUCCESS
