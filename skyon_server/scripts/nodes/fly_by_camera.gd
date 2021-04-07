extends Camera

export(bool) var disable_on_init := true

export(float) var move_speed : float = 5.0
export(float) var turn_speed : float = 10.0
export(float) var boost_speed : float = 5.0

var _mouse_move : Vector2

func _ready() -> void:
	if disable_on_init:
		disable()

func _unhandled_input(event: InputEvent) -> void:
	if _is_mouse_hidden():
		if event is InputEventMouseMotion:
			_mouse_move = event.relative
	if not _is_mouse_hidden() and event is InputEventMouseButton:
		var mouse_btn_evt = event as InputEventMouseButton
		if mouse_btn_evt.pressed and mouse_btn_evt.button_index == BUTTON_LEFT:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	if not _is_mouse_hidden():
		return
	
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

	if _mouse_move.length() > 0:
		rotation_degrees.y -= _mouse_move.x * turn_speed * delta
		rotation_degrees.x -= _mouse_move.y * turn_speed * delta
		rotation_degrees.x = clamp(rotation_degrees.x, -90, 90)
		_mouse_move = Vector2.ZERO


func disable() -> void:
	set_process_input(false)
	set_process(false)
	set_physics_process(false)
	hide()


func enable() -> void:
	set_process_input(true)
	set_process(true)
	set_physics_process(true)
	hide()


func _is_mouse_hidden() -> bool:
	return Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
