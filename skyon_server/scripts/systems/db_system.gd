class_name DBSystem
extends Node

const DB_PATH = "user://db"

var _thread: Thread
var _mutex: Mutex
var _queue: Array

var _t_running := true

func _ready() -> void:
	_mutex = Mutex.new()
	_thread = Thread.new()
	Log.ok(_thread.start(self, "_t_loop", [_mutex]))


func store(db_component: DBComponent) -> void:
	var cmd := DBCommand.new()
	cmd.is_store = true
	cmd.data = db_component.store()
	cmd.uuid = db_component.uuid

	_mutex.lock()
	_queue.push_back(cmd)
	_mutex.unlock()
	yield(cmd, "completed")


func restore(uuid: String) -> DBComponent:
	var cmd := DBCommand.new()
	cmd.is_store = false
	cmd.uuid = uuid

	_mutex.lock()
	_queue.push_back(cmd)
	_mutex.unlock()

	return yield(cmd, "completed")

func _t_loop(args: Array) -> void:
	var mutex: Mutex = args[0]

	while _t_running:
		if _queue.empty():
			OS.delay_msec(1)
			continue

		mutex.lock()
		var next := _queue.pop_back() as DBCommand
		mutex.unlock()

		if next.is_store:
			_t_store(next)
			next.emit_signal("completed")
		else:
			var result := _t_restore(next)
			next.emit_signal("completed", result)


func _t_store(cmd: DBCommand) -> void:
	var db_file := File.new()
	Log.ok(db_file.open("%s/%d" % [DB_PATH, cmd.uuid], File.WRITE))
	db_file.store_var(cmd.data)
	db_file.close()


func _t_restore(cmd: DBCommand) -> Dictionary:
	var db_file := File.new()
	var result := {}
	var path := "%s/%d" % [DB_PATH, cmd.uuid]

	if db_file.file_exists(path):
		Log.ok(db_file.open(path, File.READ))
		result = db_file.get_var()
		db_file.close()

	return result



class DBCommand:
	signal completed(result)

	var is_store: bool
	var data: Dictionary
	var uuid: String
