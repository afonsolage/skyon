extends KinematicBody

enum AIState {
	IDLE, 
	WANDER,
}

onready var _animation_tree := $AnimationTree

func set_state(state: Dictionary) -> void:
	self.translation = state.P
	self.rotation_degrees = state.R
	_animation_tree.set("parameters/speed/blend_amount", state.A)
