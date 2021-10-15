extends Control

export var root_path: NodePath

var _drag_offset := Vector2.ZERO
var _root: Control

func _ready() -> void:
	_root = get_node(root_path)
	assert(_root)

func _on_Title_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				# Grab it.
				_drag_offset = get_global_mouse_position() - _root.rect_global_position
			else:
				# Release it.
				_drag_offset = Vector2.ZERO

	if event is InputEventMouseMotion and _drag_offset != Vector2.ZERO:
		_root.set_position(get_global_mouse_position() - _drag_offset)
