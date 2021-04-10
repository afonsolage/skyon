class_name SafeYieldThread
extends Node

signal done(result)

var _thread: Thread


func run(args: Array = []):
	_thread = Thread.new()
	Log.ok(_thread.start(self, "_t_do_work", args))
	return yield(self, "done")

func _t_do_work(_args: Array) -> void:
	Log.e("You should implement _t_do_work function")
	pass

func done(result) -> void:
	self.call_deferred("_emit", result)

func _emit(result) -> void:
	_thread.wait_to_finish()
	self.emit_signal("done", result)
