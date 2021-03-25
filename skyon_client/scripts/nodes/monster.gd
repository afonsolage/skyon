extends KinematicBody

enum AIState {
	IDLE, 
	WANDER,
}

onready var _animation_tree := $AnimationTree
onready var _health_bar := $HealthBar

func set_state(state: Dictionary) -> void:
	self.translation = state.P
	self.rotation_degrees = state.R
	_animation_tree.set("parameters/speed/blend_amount", state.A)


func apply_damage(damage: int) -> void:
	Log.d("Applaying damage: %s" % damage)
	_health_bar.health -= damage
