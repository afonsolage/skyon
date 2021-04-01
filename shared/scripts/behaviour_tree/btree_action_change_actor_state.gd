class_name BTreeNodeLeafActionChangeActorState
extends BTreeNodeLeafAction

export(String) var state_variable_name: String
export(String) var state_value: String

func _tick(data: Dictionary) -> int:
	data.actor.set(state_variable_name, state_value)
	
	return _success()


