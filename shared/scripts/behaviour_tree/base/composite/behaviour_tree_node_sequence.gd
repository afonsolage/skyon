class_name BTreeNodeCompositeSequence, "../icons/sequence.png"
extends BTreeNodeComposite

onready var running_child: int = 0

func _tick(data: Dictionary) -> int:
	for i in range(running_child, .get_child_count()):
		var result = .get_child(i)._tick(data)
		
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
