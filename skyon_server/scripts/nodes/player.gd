class_name Player
extends KinematicBody
# This is a data and signal holding class. Only logic related to signal emmiting
# and data manipulation are allowed.

signal area_of_interest_entered(body)
signal area_of_interest_exited(body)

export(float) var move_speed := 3.0
export(float) var boost_speed := 6.0
export(float) var turn_speed := 3.0
export(float) var jump_force := 5.0

var session_id: int

onready var combat := CombatComponent.new(self)
onready var gravity := GravityComponent.new(self)

onready var _area_of_interest: Area = $AreaOfInterest
onready var _interaction_area: Area = $InteractionArea

func _ready() -> void:
	session_id = int(self.name.right(1))
	combat.defense *= 3


func _to_string() -> String:
	return self.name


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


func get_interaction_area_bodies() -> Array:
	return _interaction_area.get_overlapping_bodies()


func get_area_of_interest_bodies() -> Array:
	return _area_of_interest.get_overlapping_bodies()


func _on_AreaOfInterest_body_entered(body):
	if body == self:
		return
	
	self.emit_signal("area_of_interest_entered", body)


func _on_AreaOfInterest_body_exited(body):
	if body == self:
		return
		
	self.emit_signal("area_of_interest_exited", body)
