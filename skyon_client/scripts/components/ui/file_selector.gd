extends HBoxContainer

onready var file_dialog := $FileDialog
onready var path := $Value/Path


func _on_ChoosePath_pressed():
	file_dialog.show_modal(true)


func _on_FileDialog_file_selected(selected_path):
	self.path.text = selected_path
