extends Viewport


func _unhandled_input(event):
	get_camera()._unhandled_input(event)
