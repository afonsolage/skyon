class_name ConnectionArea
extends Spatial

signal on_body_entered(body)

func _on_TeleportArea_body_entered(body) -> void:
	self.emit_signal("on_body_entered", body)
