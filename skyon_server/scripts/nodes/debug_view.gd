class_name DebugView
extends Control

var selected_channel_id := -1

var _channel_item_id: Dictionary = {}
var _current_camera: Camera = null

onready var _texture_render = $Control/RenderView
onready var _item_list: ItemList = $Control/VBoxContainer/ItemList
onready var _label: Label = $Control/Label

func _ready() -> void:
	Log.ok(Systems.channel.connect("channel_loaded", self, "_on_channel_loaded"))
	Log.ok(Systems.channel.connect("channel_unloaded", self, "_on_channel_unloaded"))

func _process(_delta: float) -> void:
	if selected_channel_id == -1 or Systems.channel.get_child_count() == 0:
		return
	
	if not _texture_render.texture:
		var vp = _get_selected_viewport()
		_current_camera = vp.get_camera()
		_current_camera.enable()
		_texture_render.texture = vp.get_texture()

func _on_channel_loaded(channel_id: int) -> void:
	var item_idx = _item_list.get_item_count()
	_item_list.add_item("Channel %s" % Systems.atlas.calc_map_pos(channel_id))
	_channel_item_id[channel_id] = item_idx
	_item_list.set_item_metadata(item_idx, channel_id)


func _on_channel_unloaded(channel_id: int) -> void:
	_item_list.remove_item(_channel_item_id[channel_id])
	var _erased = _channel_item_id.erase(channel_id)


func _on_ItemList_item_selected(index):
	_texture_render.texture = null
	
	var vp := _get_selected_viewport()
	
	if vp:
		vp.get_camera().disable()
	
	if index == 0:
		selected_channel_id = -1
		_label.text = "No channel selected"
	else:
		var channel_id := _item_list.get_item_metadata(index) as int
		selected_channel_id = channel_id
		_label.text = "Viewing channel %d" % channel_id


func _get_selected_viewport() -> Viewport:
	if selected_channel_id > -1:
		return Systems.get_world(selected_channel_id).get_parent() as Viewport
	else:
		return null
