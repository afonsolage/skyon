extends Camera

export(float) var move_speed : float = 5.0
export(float) var turn_speed : float = 10.0
export(float) var boost_speed : float = 2.0

var _mouse_move : Vector2

func _input(event: InputEvent) -> void:
	if _is_mouse_hidden() and event is InputEventMouseMotion:
		_mouse_move = event.relative

func _physics_process(delta: float) -> void:
	var boost := boost_speed if Input.is_key_pressed(KEY_SHIFT) else 1.0
	
	if Input.is_key_pressed(KEY_W):
		self.transform.origin -= self.transform.basis.z * move_speed * boost * delta
	elif Input.is_key_pressed(KEY_S):
		self.transform.origin += self.transform.basis.z * move_speed * boost * delta

	if Input.is_key_pressed(KEY_D):
		self.transform.origin += self.transform.basis.x * move_speed * boost * delta
	elif Input.is_key_pressed(KEY_A):
		self.transform.origin -= self.transform.basis.x * move_speed * boost * delta
	
	if _is_mouse_hidden() and Input.is_key_pressed(KEY_ESCAPE):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif not _is_mouse_hidden() and Input.is_mouse_button_pressed(BUTTON_LEFT):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if _mouse_move.length() > 0:
		rotation_degrees.y -= _mouse_move.x * turn_speed * delta
		rotation_degrees.x -= _mouse_move.y * turn_speed * delta
		rotation_degrees.x = clamp(rotation_degrees.x, -90, 90)
		_mouse_move = Vector2.ZERO
	

func _is_mouse_hidden() -> bool:
	return Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
