class_name BTreeNodeCompositeSelector, "../icons/selector.png"
extends BTreeNodeComposite

onready var running_child: int = 0

func _tick(data: Dictionary) -> int:
	for i in range(running_child, .get_child_count()):
		var result = .get_child(i)._tick(data)
		
		match result:
			BTreeResult.SUCCESS:
				return _success()
			BTreeResult.RUNNING:
				running_child = i
				return _running()
			BTreeResult.FAILURE:
				continue
	
	return _failure()


func _success() -> int:
	running_child = 0
	return ._success()


func _failure() -> int:
	running_child = 0
	return ._failure()
