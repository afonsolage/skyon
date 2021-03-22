extends Object

class_name GravityBody

export(float) var force := 0.0

var _body : KinematicBody
var _magnitude : float

func _init(body: KinematicBody) -> void:
	_magnitude = ProjectSettings.get_setting("physics/3d/default_gravity")
	_body = body


func apply(delta: float) -> void:
	force -= _magnitude * delta
	force = _body.move_and_slide(Vector3(0, force, 0), Vector3.UP).y

func jump(jump_force: float) -> void:
	force += jump_force


func is_grounded() -> bool:
	return force > -0.001 and force < 0.001
