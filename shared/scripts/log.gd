class_name Log
extends Object

static func i(msg) -> void:
	_l("I", msg)


static func e(msg) -> void:
	_l("E", msg, true)


static func d(msg) -> void:
	if OS.is_debug_build():
		_l("D", msg)


static func ok(err: int) -> void:
	if err != OK:
		_l("E", "Error code %d returned" % err)


static func _l(type: String, msg, is_err: bool = false) -> void:
	var stack := get_stack()
	
	var tm := OS.get_time()
	var callee: Dictionary = stack[2] if stack.size() > 3 else stack[1]
	var logmsg = "[%s][%02d:%02d:%02d][%s] %s" % [
		type, 
		tm.hour, 
		tm.minute,
		tm.second,
		callee.source.replace("res://scripts/", ""),
		msg,
	]
	if is_err:
		printerr(logmsg)
	else:
		print(logmsg)
