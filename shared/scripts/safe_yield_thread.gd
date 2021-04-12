class_name SafeYieldThread
extends Node

signal done(result)

var _thread: Thread
var _debug
var _res_debug

func run(args: Array = []):
	if _debug:
		_t_do_work(args)
		return _res_debug
	else:
		_thread = Thread.new()
		Log.ok(_thread.start(self, "_t_do_work", args))
		return yield(self, "done")

func _t_do_work(_args: Array) -> void:
	Log.e("You should implement _t_do_work function")
	pass
	
func done(result) -> void:
	if _debug:
		_res_debug = result
	else:
		self.call_deferred("_emit", result)

func _emit(result) -> void:
	_thread.wait_to_finish()
	self.emit_signal("done", result)
