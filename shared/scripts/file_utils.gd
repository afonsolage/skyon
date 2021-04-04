class_name FileUtils

static func ensure_user_path_exists(path: String) -> void:
	var directory := Directory.new()
	if not directory.dir_exists(path):
		Log.ok(directory.open("user://"))
		Log.ok(directory.make_dir_recursive(path))


static func exists(path: String) -> bool:
	return File.new().file_exists(path)
