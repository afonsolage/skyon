class_name DBSystem
extends Node

const DB_HOST = "localhost"
const DB_PORT = 3000

var _connection := DBConnection.new()

func _ready() -> void:
	if not _connection.start():
		Log.e("Failed to start connection with database!")
	else:
		Log.i("Database connection started!")

	

func post(endpoint: String, value: Dictionary) -> void:
	var cmd := DBCmd.new()
	cmd.args = {
		"method": "POST",
		"endpoint": endpoint,
		"value": value,
	}
	
	var _r = yield(_connection.run(cmd), "completed")


func get(endpoint: String) -> Array:
	var cmd := DBCmd.new()
	cmd.args = {
		"method": "GET",
		"endpoint": endpoint,
	}
	
	return yield(_connection.run(cmd), "completed")


func delete(endpoint: String, condition: String) -> void:
	var cmd := DBCmd.new()
	cmd.args = {
		"method": "DELETE",
		"endpoint": endpoint,
		"condition": condition
	}
	
	return yield(_connection.run(cmd), "completed")


class DBCmd:
	signal done(result)
	
	var args: Dictionary
	
	func done(result: Array) -> void:
		Log.d("Cmd done %s = %s" % [self, result])
		emit_signal("done", result)

	func _to_string() -> String:
		return str(args)

class DBConnection:
	var _http := HTTPClient.new()
	var _semaphore = Semaphore.new()
	var _mutex := Mutex.new()
	var _queue := []
	var _running: bool
	var _thread: Thread
	
	func start() -> bool:
		Log.ok(_http.connect_to_host(DB_HOST, DB_PORT))
		
		while _http.get_status() in [HTTPClient.STATUS_CONNECTING, HTTPClient.STATUS_RESOLVING]:
			Log.ok(_http.poll())
			OS.delay_msec(1)
		
		_running = _http.get_status() == HTTPClient.STATUS_CONNECTED
		
		if _running:
			_thread = Thread.new()
			Log.ok(_thread.start(self, "_t_run"))
		
		return _running
	
	
	func stop() -> void:
		_running = false
		_semaphore.post()
		_thread.wait_to_finish()
	
	
	func run(cmd: DBCmd) -> Array:
		_mutex.lock()
		_queue.push_back(cmd)
		_mutex.unlock()
		_semaphore.post()
		return yield(cmd, "done")
	
	
	func _t_run(_args) -> void:
		while _running:
			_semaphore.wait()
			
			var cmd: DBCmd
			_mutex.lock()
			cmd = _queue.pop_front()
			_mutex.unlock()
			
			if cmd:
				Log.d("Running cmd %s" % cmd)
				_execute(cmd)
	
	
	func _execute(cmd: DBCmd) -> void:
		var result: Array
		
		var args := cmd.args
		match args.method:
			"POST":
				result = _request(args.endpoint, HTTPClient.METHOD_POST, [], to_json(args.value))
			"GET":
				result = _request(args.endpoint, HTTPClient.METHOD_GET)
			"DELETE":
				result = _request("%s?%s" % [args.endpoint, args.condition], HTTPClient.METHOD_DELETE)
		
		cmd.call_deferred("done", result)
	
	
	func _request(endpoint: String, method: int, headers: Array = [], body: String = "") -> Array:
		Log.ok(_http.request_raw(method, endpoint, PoolStringArray(headers), body.to_ascii()))
		
		while _http.get_status() == HTTPClient.STATUS_REQUESTING:
			Log.ok(_http.poll())
			OS.delay_msec(1)
		
		if not _http.get_status() in [HTTPClient.STATUS_BODY, HTTPClient.STATUS_CONNECTED]:
			Log.e("Failed to send request to endpoint %s" % endpoint)
			return []

		if _http.has_response():
			var response_buffer := PoolByteArray()
			
			while _http.get_status() == HTTPClient.STATUS_BODY:
				Log.ok(_http.poll())
				var chunk := _http.read_response_body_chunk()
				if chunk.size() == 0:
					OS.delay_msec(1)
				else:
					response_buffer = response_buffer + chunk
			
			if _http.get_response_code() < 300:
				var raw := response_buffer.get_string_from_ascii()
				if raw and not raw.empty():
					Log.d(raw)
					return parse_json(raw)
			else:
				Log.e("[%d] %s" % [_http.get_response_code(), response_buffer.get_string_from_ascii()])
		
		return []
