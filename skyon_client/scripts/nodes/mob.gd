class_name Mob
extends KinematicBody

var combat: CombatComponent

onready var _animation_tree := $AnimationTree
onready var _health_bar := $HealthBar

func _init():
	combat = CombatComponent.new(self)
	Log.ok(combat.connect("health_changed", self, "_on_health_changed"))


func set_state(state: Dictionary) -> void:
	self.translation = state.P
	self.rotation_degrees = state.R
	_parse_current_action(state.A)
	


func set_full_state(state: Dictionary) -> void:
	set_state(state.S)
	
	combat.decode(state.C)


func _on_health_changed() -> void:
	_health_bar.max_health = combat.max_health
	_health_bar.health = combat.health


func _parse_current_action(action: String) -> void:
	match action:
		"Idle":
			_animation_tree.set("parameters/speed/blend_amount", 0)
		"Walking":
			_animation_tree.set("parameters/speed/blend_amount", 1)
		_:
			Log.e("Unknown action: %s" % action)
