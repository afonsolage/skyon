class_name BTreeNodeCompositeSequence, "../icons/sequence.png"
extends BTreeNodeComposite

export(bool) var reactive: bool = false
export(bool) var print_children_actions: bool = false

onready var running_child: int = 0

func _tick(data: Dictionary) -> int:
	var start = 0 if reactive else running_child
	
	for i in range(start, get_child_count()):
		var child = get_child(i)
		
		if not child.enabled:
			continue
		
		var result = child._tick(data)
		
		if print_children_actions and (child is BTreeNodeLeaf or child is BTreeNodeLeafCondition):
			Log.d("%s = [%d]" % [child._get_tree_branch(), result])
			
		match result:
			BTreeResult.SUCCESS:
				continue
			BTreeResult.RUNNING:
				running_child = i
				return _running()
			BTreeResult.FAILURE:
				return _failure()
	
	return _success()


func _success() -> int:
	running_child = 0
	return ._success()


func _failure() -> int:
	running_child = 0
	return ._failure()


func _reset() -> void:
	running_child = 0
	._reset()
