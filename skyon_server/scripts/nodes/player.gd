class_name Player
extends KinematicBody

signal area_of_interest_entered(body)
signal area_of_interest_exited(body)

export(float) var move_speed := 3.0
export(float) var boost_speed := 6.0
export(float) var turn_speed := 3.0
export(float) var jump_force := 5.0

var session_id: int

var _gravity_body: GravityBody

onready var combat := CombatComponent.new(self)
onready var area_of_interest: Area = $AreaOfInterest
onready var _attack_area: Area = $AttackArea

func _ready() -> void:
	_gravity_body = GravityBody.new(self)
	session_id = int(self.name.right(1))

func _physics_process(delta):
	_gravity_body.apply(delta)


func get_state() -> Dictionary:
	return {
		"P": self.translation,
		"R": self.rotation_degrees,
		"A": 0, #TODO: Set animation
	}

func get_full_state() -> Dictionary:
	return {
		"S": get_state(),
		"C": combat,
	}


func set_state(state: Dictionary) -> void:
	self.translation = state.P
	self.rotation_degrees = state.R


func move(new_position: Vector3) -> bool:
	var offset := new_position - self.transform.origin
	
	if offset.length() > 0.01:
		# TODO: Add collisions check
		self.transform.origin = new_position
	
	return true


func get_attack_target() -> Spatial:
	var bodies = _attack_area.get_overlapping_bodies()
	
	for body in bodies:
		if body is Spatial and body.is_in_group("Enemy"):
			return body as Spatial
	
	return null


func _on_AreaOfInterest_body_entered(body):
	if body == self:
		return
	
	self.emit_signal("area_of_interest_entered", body)


func _on_AreaOfInterest_body_exited(body):
	if body == self:
		return
		
	self.emit_signal("area_of_interest_exited", body)
