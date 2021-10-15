extends TextureRect

onready var _icon = $MarginContainer/Icon

func set_icon(path: String) -> void:
	_icon.texture = load(path)
