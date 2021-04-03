class_name BTreeNodeDecoratorLimiter, "../icons/decorator.png"
extends BTreeNodeDecorator

export(int) var max_count = -1

var _count: int = 0

func _tick(data: Dictionary) -> int:
	if _count <= max_count:
		_count += 1
		return .get_child(0).tick(data)
	else:
		return BTreeResult.FAILURE


func _reset() -> void:
	_count = 0
