class_name UISystem
extends Node

enum Window {
	INVENTORY,
}

const WINDOWS_RES = {
	Window.INVENTORY: preload("res://systems/ui/nodes/window/inventory.tscn") 
}

onready var _main_player_portrait: MainPlayerPortrait = $MainPlayerPortrait
onready var _windows_node: Control = $Windows

var _windows: Dictionary = {}


func _ready():
	Log.d("Initializing UI System")


func _on_PlayerSystem_health_changed(health, max_health):
	_main_player_portrait.update_health(health, max_health)


func show_window(window: int) -> void:
	assert(WINDOWS_RES.has(window))
	
	if _windows.has(window):
		Log.w("Window %d is already shown" % window)
		return
	
	Log.d("Showing window %d" % window)
	
	var new_window := WINDOWS_RES[window].instance() as Control
	_windows_node.add_child(new_window)
	_windows[window] = new_window


func close_window(window: int) -> void:
	assert(WINDOWS_RES.has(window))
	
	if not _windows.has(window):
		Log.w("Window %d isn't shown" % window)
		return
		
	Log.d("Closed window %d" % window)
	
	_windows[window].queue_free()
	var _b = _windows.erase(window)


func is_window_shown(window: int) -> bool:
	return _windows.has(window)
