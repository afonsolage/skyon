extends KinematicBody

export(float) var move_speed := 3.0
export(float) var boost_speed := 6.0
export(float) var turn_speed := 3.0
export(float) var jump_force := 5.0

var _gravity_body: GravityBody
var session_id: int

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


func move(new_position: Vector3) -> bool:
	var offset := new_position - self.transform.origin
	
	if offset.length() > 0.01:
		# TODO: Add collisions check
		self.transform.origin = new_position
	
	return true
