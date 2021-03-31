class_name BTreeNodeLeafActionFindRandomPlace
extends BTreeNodeLeafAction

export(float) var max_radius:float = 10.0
export(float) var min_radius:float = 2.0

func _tick(data: Dictionary) -> int:
	
	var actor as Node
	
	return BTreeResult.SUCCESS
