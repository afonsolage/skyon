extends Spatial


func set_state(state: Dictionary) -> void:
	self.translation = state.P


func set_full_state(state: Dictionary) -> void:
	set_state(state.S)

