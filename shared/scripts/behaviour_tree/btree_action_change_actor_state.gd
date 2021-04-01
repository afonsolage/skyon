class_name BTreeNodeLeafActionChangeActorState
extends BTreeNodeLeafAction

export(String) var state_variable_name: String
export(String) var state_value: String

var _previous_state: String

func _tick(data: Dictionary) -> int:
	_previous_state = data.actor.get(state_variable_name)
	if _previous_state != state_value:
		Log.d("Set %s to %s" % [state_variable_name, state_value])
		data.actor.set(state_variable_name, state_value)
	
	return _success()


