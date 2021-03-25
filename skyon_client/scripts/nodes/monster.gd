extends KinematicBody

enum AIState {
	IDLE, 
	WANDER,
}

var combat: CombatComponent

onready var _animation_tree := $AnimationTree
onready var _health_bar := $HealthBar

func set_state(state: Dictionary) -> void:
	self.translation = state.P
	self.rotation_degrees = state.R
	_animation_tree.set("parameters/speed/blend_amount", state.A)


func set_full_state(state: Dictionary) -> void:
	set_state(state.S)
	
	combat = CombatComponent.new(self)
	combat.decode(state.C)


func apply_damage(damage: int) -> void:
	Log.d("Applaying damage: %s" % damage)
	_health_bar.health -= damage
