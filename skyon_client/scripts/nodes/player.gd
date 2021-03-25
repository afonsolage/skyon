class_name MainPlayer
extends KinematicBody

export(float) var move_speed := 3.0

var is_busy : bool

var gravity := GravityComponent.new(self)

var _state: Dictionary

onready var _animation_tree: AnimationTree = $AnimationTree
onready var _interaction_area : Area = $InteractionArea
onready var _wall_raycast : RayCast = $WallRayCast

func _physics_process(_delta: float) -> void:
	_send_state()


func is_on_wall() -> bool:
	return _wall_raycast.is_colliding()


func _send_state() -> void:
	_state = {
		"T": OS.get_system_time_msecs(),
		"P": self.translation,
		"R": self.rotation_degrees
	}
	Systems.world.send_state(_state)


func _attacking_started() -> void:
	is_busy = true


func _attacking_ended() -> void:
	is_busy = false


func get_interaction_area_bodies() -> Array:
	return _interaction_area.get_overlapping_bodies()


func start_attack_animation() -> void:
	_animation_tree.set("parameters/attack/active", true)


func set_walking() -> void:
	_animation_tree.set("parameters/speed/blend_amount", 1.0)


func set_idle() -> void:
	_animation_tree.set("parameters/speed/blend_amount", 0.0)

