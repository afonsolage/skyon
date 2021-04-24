extends Control

var _items: Dictionary

var _materials_root: TreeItem
var _usables_root: TreeItem
var _equipment_root: TreeItem
var _special_root: TreeItem

var _dummy_root: TreeItem

onready var items_tree := $Box/Content/Left/VContainer/ItemsTree

onready var equipment_model_spatial := $ModelVP/Model
onready var icon_preview := $Box/Content/Mid/VBoxContainer/VBoxContainer/IconPreview

onready var sub_category_value := $Box/Content/Right/VBoxContainer/SubCategory/Value
onready var category_value := $Box/Content/Right/VBoxContainer/Category/Value
onready var name_value := $Box/Content/Right/VBoxContainer/Name/Value
onready var description_value := $Box/Content/Right/VBoxContainer/Description/Value
onready var icon_value := $Box/Content/Right/VBoxContainer/Icon/Value/Path
onready var max_stack_value := $Box/Content/Right/VBoxContainer/MaxStack/Value
onready var req_proficiency_value := $Box/Content/Right/VBoxContainer/ReqProficiency/Value
onready var action_value := $Box/Content/Right/VBoxContainer/Usable/Action/Value
onready var model_value := $Box/Content/Right/VBoxContainer/Equipment/Model/Value/Path
onready var slot_value := $Box/Content/Right/VBoxContainer/Equipment/Slot/Value
onready var skill_list_value := $Box/Content/Right/VBoxContainer/Equipment/SkillList/SkillListBg/Scroll/SkillList/AddSkillPanel/SkillListOpts
onready var attr_list_value := $Box/Content/Right/VBoxContainer/Equipment/AttributeList/AttrListBg/Scroll/AttrList/AddAttrPanel/AttrListOpts

onready var right_container := $Box/Content/Right/VBoxContainer
onready var mid_container := $Box/Content/Mid/VBoxContainer
onready var model_preview_container := $Box/Content/Mid/VBoxContainer/ModelPreview
onready var equipment_container := $Box/Content/Right/VBoxContainer/Equipment
onready var usable_container := $Box/Content/Right/VBoxContainer/Usable

onready var add_skill_opts := $Box/Content/Right/VBoxContainer/Equipment/SkillList/SkillListBg/Scroll/SkillList/AddSkillPanel/SkillListOpts
onready var add_skill_rate := $Box/Content/Right/VBoxContainer/Equipment/SkillList/SkillListBg/Scroll/SkillList/AddSkillPanel/HBoxContainer/Rate
onready var add_skill_model := $Box/Content/Right/VBoxContainer/Equipment/SkillList/SkillListBg/Scroll/SkillList/Skills/Model
onready var skill_list_container := $Box/Content/Right/VBoxContainer/Equipment/SkillList/SkillListBg/Scroll/SkillList/Skills/VBoxContainer

onready var add_attr_opts := $Box/Content/Right/VBoxContainer/Equipment/AttributeList/AttrListBg/Scroll/AttrList/AddAttrPanel/AttrListOpts
onready var add_attr_amount := $Box/Content/Right/VBoxContainer/Equipment/AttributeList/AttrListBg/Scroll/AttrList/AddAttrPanel/HBoxContainer/Amount
onready var add_attr_model := $Box/Content/Right/VBoxContainer/Equipment/AttributeList/AttrListBg/Scroll/AttrList/Attrs/Model
onready var attr_list_container := $Box/Content/Right/VBoxContainer/Equipment/AttributeList/AttrListBg/Scroll/AttrList/Attrs/VBoxContainer

onready var load_dialog := $Box/PanelContainer/Menu/LoadBtn/LoadDialog
onready var save_dialog := $Box/PanelContainer/Menu/SaveBtn/SaveDialog

func _ready() -> void:
	right_container.visible = false
	mid_container.visible = false
	model_preview_container.visible = false
	
	_setup_tree()
	_setup_controls()


func _process(delta: float) -> void:
	equipment_model_spatial.global_rotate(Vector3.UP, 1.0 * delta)


func _input(event: InputEvent):
	if event is InputEventKey:
		var key_event := event as InputEventKey
		
		if Input.is_key_pressed(KEY_CONTROL) and key_event.pressed:
			match key_event.scancode:
				KEY_A:
					_on_AddItemBtn_pressed()
				KEY_D:
					_duplicate_selected_item()
		


func _setup_tree() -> void:
	_dummy_root = items_tree.create_item()
	
	_materials_root = items_tree.create_item()
	_materials_root.set_text(0, "Materials")
	
	_usables_root = items_tree.create_item()
	_usables_root.set_text(0, "Usables")
	
	_equipment_root = items_tree.create_item()
	_equipment_root.set_text(0, "Equipments")
	
	_special_root = items_tree.create_item()
	_special_root.set_text(0, "Specials")


func _setup_controls() -> void:
	_setup_enum_options_control(req_proficiency_value, Consts.ProficiencyID)
	_setup_enum_options_control(action_value, Consts.ItemActionID)
	_setup_enum_options_control(slot_value, Consts.EquipmentSlot)
	_setup_enum_options_control(skill_list_value, Consts.SkillID)
	_setup_enum_options_control(attr_list_value, Consts.AttributeID)


func _reset_form() -> void:
	right_container.visible = true
	mid_container.visible = true
	equipment_container.visible = false
	model_preview_container.visible = false
	usable_container.visible = false
	
	add_skill_opts.selected = 0
	add_skill_rate.get_line_edit().text = "0 %"
	for i in skill_list_container.get_child_count():
		skill_list_container.get_child(i).queue_free()
	
	add_attr_opts.selected = 0
	add_attr_amount.get_line_edit().text = "0"
	for i in attr_list_container.get_child_count():
		attr_list_container.get_child(i).queue_free()

	category_value.text = "None"
	sub_category_value.selected = 0
	name_value.text = ""
	icon_value.text = ""
	description_value.text = ""
	max_stack_value.get_line_edit().text = ""
	req_proficiency_value.selected = 0
	action_value.selected = 0
	model_value.text = ""
	slot_value.selected = 0
	skill_list_value.selected = 0
	attr_list_value.selected = 0
	

func _load_item(item: ItemResource) -> void:
	match item.category:
		Consts.ItemCategory.MATERIAL:
			_setup_enum_options_control(sub_category_value, Consts.MaterialCategory)
		Consts.ItemCategory.USABLE:
			_setup_enum_options_control(sub_category_value, Consts.UsableCategory)
			usable_container.visible = true
			action_value.selected = (item as UsableItemResource).action
		Consts.ItemCategory.EQUIPMENT:
			_setup_enum_options_control(sub_category_value, Consts.EquipmentCategory)
			equipment_container.visible = true
			model_preview_container.visible = true
			var equipment_item := item as EquipmentItemResource
			model_value.text = equipment_item.model_path
			slot_value.selected = equipment_item.slot
			
			for arr in equipment_item.skill_list:
				_add_skill_list_item(arr[0], int(arr[1]))
				
			for arr in equipment_item.attribute_list:
				_add_attribute_list_item(arr[0], int(arr[1]))
			
			if equipment_model_spatial.get_child_count() > 0:
				equipment_model_spatial.get_child(0).queue_free()
			
			if not equipment_item.model_path.empty():
				equipment_model_spatial.add_child(load(equipment_item.model_path).instance())
			
		Consts.ItemCategory.SPECIAL:
			_setup_enum_options_control(sub_category_value, Consts.SpecialCategory)
		_:
			Log.e("Invalid category: %d" % item.category)
	
	category_value.text = Consts.ItemCategory.keys()[item.category]
	sub_category_value.selected = item.sub_category
	name_value.text = item.name
	icon_value.text = item.icon_path
	description_value.text = item.description
	max_stack_value.get_line_edit().text = str(item.max_stack_count)
	req_proficiency_value.selected = item.required_proficiency
	
	if item.icon_path.empty():
		icon_preview.texture = null
	else:
		icon_preview.texture = load(item.icon_path)


func _setup_enum_options_control(opt: OptionButton, enum_value: Dictionary) -> void:
	opt.clear()
	for k in enum_value.keys():
		opt.add_item(k, enum_value[k])


func _get_root(tree_item: TreeItem) -> TreeItem:
	var item := tree_item
	
	while not item.get_parent() == _dummy_root:
		item = item.get_parent()
		
		if not item:
			return null
	
	return item


func _get_parent_category(parent: TreeItem) -> int:
	match parent.get_text(0):
		"Materials":
			return Consts.ItemCategory.MATERIAL
		"Usables":
			return Consts.ItemCategory.USABLE
		"Equipments":
			return Consts.ItemCategory.EQUIPMENT
		"Specials":
			return Consts.ItemCategory.SPECIAL
		_:
			Log.e("Unknown category: %s" % parent.get_text(0))
			return -1


func _get_current_item() -> ItemResource:
	var selected_item := items_tree.get_selected() as TreeItem
	
	if selected_item:
		var meta = selected_item.get_metadata(0)
		if meta and "uuid" in meta:
			return _items[meta.uuid]
	
	return null


func _duplicate_selected_item() -> void:
	var selected_item = _get_current_item()
	if not selected_item:
		return
	
	var copy = dict2inst(inst2dict(selected_item)) as ItemResource
	copy.uuid = UUID.v4()
	copy.name = "New Item %d" % _items.size()
	
	_items[copy.uuid] = copy
	
	_add_item_tree(copy)


func _add_skill_list_item(skill_id: int, rate: int) -> void:
	var added_skill := add_skill_model.duplicate()
	added_skill.get_child(0).text = Consts.SkillID.keys()[skill_id]
	added_skill.get_child(1).text = "%d%%" % rate
	added_skill.visible = true
	
	Log.ok(added_skill.get_child(2).connect(
		"pressed", 
		self, 
		"_on_remove_skill_pressed",
		[skill_id]))
	
	skill_list_container.add_child(added_skill)
	

func _add_attribute_list_item(attribute_id: int, amount: int) -> void:
	var added_attr:= add_attr_model.duplicate()
	added_attr.get_child(0).text = Consts.AttributeID.keys()[attribute_id]
	added_attr.get_child(1).text = str(amount)
	added_attr.visible = true
	
	Log.ok(added_attr.get_child(2).connect(
		"pressed", 
		self, 
		"_on_remove_attr_pressed",
		[attribute_id]))
	
	attr_list_container.add_child(added_attr)


func _save_current_item():
	var item_resource := _get_current_item()
	
	if not item_resource:
		return
	
	item_resource.sub_category = sub_category_value.selected
	item_resource.name = name_value.text
	item_resource.icon_path = icon_value.text
	item_resource.description = description_value.text
	item_resource.max_stack_count = int(max_stack_value.get_line_edit().text)
	item_resource.required_proficiency = req_proficiency_value.selected
	
	if item_resource.category == Consts.ItemCategory.USABLE:
		(item_resource as UsableItemResource).action = action_value.selected
	elif item_resource.category == Consts.ItemCategory.EQUIPMENT:
		var equipment_item := item_resource as EquipmentItemResource
		equipment_item.slot = slot_value.selected
		equipment_item.model_path = model_value.text

	var tree_item := items_tree.get_selected() as TreeItem
	if tree_item and not item_resource.name.empty():
		tree_item.set_text(0, item_resource.name)


func _update_item_tree() -> void:
	right_container.visible = false
	mid_container.visible = false
	
	items_tree.clear()
	_setup_tree()
		
	
	for item_resource in _items.values():
		_add_item_tree(item_resource)


func _add_item_tree(item_resource: ItemResource) -> void:
	var parent: TreeItem
	match item_resource.category:
		Consts.ItemCategory.MATERIAL:
			parent = _materials_root
		Consts.ItemCategory.USABLE:
			parent = _usables_root
		Consts.ItemCategory.EQUIPMENT:
			parent = _equipment_root
		Consts.ItemCategory.SPECIAL:
			parent = _special_root
		_:
			Log.e("Unknown category %d on item %s" % [item_resource.category, item_resource])
			return
	
	var new_item := items_tree.create_item(parent) as TreeItem
	new_item.set_text(0, item_resource.name)
	new_item.set_metadata(0, {"uuid": item_resource.uuid})
	new_item.select(0)


func _filter_client_properties(item_dict: Dictionary) -> Dictionary:
	for key in item_dict.keys():
		match key:
			"skill_list":
				item_dict["skill_list"] = []
			"attribute_list":
				item_dict["attribute_list"] = []
			"action":
				item_dict["action"] = ""
		pass
	
	return item_dict


func _on_AddItemBtn_pressed():
	var tree_item := items_tree.get_selected() as TreeItem
	
	if not tree_item:
		return
	
	var parent := _get_root(tree_item)
	if not parent:
		return
	
	var category := _get_parent_category(parent)
	if category == -1:
		return
	
	var item_resource: ItemResource
	match category:
		Consts.ItemCategory.MATERIAL:
			item_resource = MaterialItemResource.new()
		Consts.ItemCategory.USABLE:
			item_resource = UsableItemResource.new()
		Consts.ItemCategory.EQUIPMENT:
			item_resource = EquipmentItemResource.new()
		Consts.ItemCategory.SPECIAL:
			item_resource = SpecialItemResource.new()
		_:
			Log.e("Invalid category: %d" % category)
			return
		
	item_resource.category = category
	item_resource.uuid = UUID.v4()
	item_resource.name = "New Item %d" % _items.size()
	
	_items[item_resource.uuid] = item_resource
	
	_add_item_tree(item_resource)


func _on_ItemsTree_item_selected():
	var item_resource := _get_current_item()
	
	if item_resource:
		_reset_form()
		_load_item(item_resource)
	else:
		right_container.visible = false
		mid_container.visible = false

func _on_AddSkill_pressed():
	var selected_skill := add_skill_opts.selected as int
	var added_skill_rate := int(add_skill_rate.get_line_edit().text.trim_suffix(" %"))
	
	var current_item := _get_current_item()
	
	for arr in current_item.skill_list:
		if arr[0] == selected_skill:
			Log.e("You can't add the same skill twice!")
			return
	
	current_item.skill_list.push_back([
		selected_skill,
		added_skill_rate,
	])
	
	_add_skill_list_item(selected_skill, added_skill_rate)


func _on_remove_skill_pressed(skill_id: int) -> void:
	var current_item := _get_current_item()
	
	var idx := -1
	for i in current_item.skill_list.size():
		var arr = current_item.skill_list[i]
		if arr[0] == skill_id:
			idx = i
			break
	
	if idx == -1:
		Log.e("Unable to remove skill. Skill id not found: %d" % skill_id)
		return

	current_item.skill_list.remove(idx)

	idx = -1
	var skill_key := Consts.SkillID.keys()[skill_id] as String
	for i in skill_list_container.get_child_count():
		var child := skill_list_container.get_child(i)
		if child.get_child(0).text == skill_key:
			child.queue_free()
			return
	
	Log.e("Unable to remove skill. Skill key not found: %s" % skill_key)


func _on_AddAttr_pressed():
	var selected_attr := add_attr_opts.selected as int
	var added_attr_amount := int(add_attr_amount.get_line_edit().text)
	
	var current_item := _get_current_item()
	for arr in current_item.attribute_list:
		if arr[0] == selected_attr:
			Log.e("You can't add the same attribute twice!")
			return
	
	current_item.attribute_list.push_back([
		selected_attr,
		added_attr_amount,
	])
	
	_add_attribute_list_item(selected_attr, added_attr_amount)


func _on_remove_attr_pressed(attr_id: int) -> void:
	var current_item := _get_current_item()
	
	var idx := -1
	for i in current_item.attribute_list.size():
		var arr = current_item.attribute_list[i]
		if arr[0] == attr_id:
			idx = i
			break
	
	if idx == -1:
		Log.e("Unable to remove attribute. Attribute id not found: %d" % attr_id)
		return

	current_item.attribute_list.remove(idx)

	idx = -1
	var attr_key := Consts.AttributeID.keys()[attr_id] as String
	for i in attr_list_container.get_child_count():
		var child := attr_list_container.get_child(i)
		if child.get_child(0).text == attr_key:
			child.queue_free()
			return
	
	Log.e("Unable to remove attribute. Attribute key not found: %s" % attr_key)


func _on_AutoSave_timeout():
	if not right_container.visible:
		return
	
	_save_current_item()


func _on_IconFileDialog_file_selected(path: String):
	var texture := load(path)
	icon_preview.texture = texture


func _on_IconClearPath_pressed():
	icon_preview.texture = null


func _on_ModelFileDialog_file_selected(path: String):
	var model = load(path).instance()
	
	if equipment_model_spatial.get_child_count() > 0:
		equipment_model_spatial.get_child(0).queue_free()
	
	equipment_model_spatial.add_child(model)


func _on_ModelClearPath_pressed():
	if equipment_model_spatial.get_child_count() > 0:
		equipment_model_spatial.get_child(0).queue_free()


func _on_LoadBtn_pressed():
	load_dialog.show()
	load_dialog.invalidate()


func _on_SaveBtn_pressed():
	save_dialog.show()


func _on_LoadDialog_file_selected(path: String) -> void:
	_items.clear()

	var file := File.new()

	Log.ok(file.open_compressed(path, File.READ, File.COMPRESSION_ZSTD))
	var loaded_items := file.get_var() as Array
	file.close()

	for item_dict in loaded_items:
		var item_resource := dict2inst(item_dict) as ItemResource
		_items[item_resource.uuid] = item_resource

	_update_item_tree()


func _on_SaveDialog_dir_selected(dir):
	var server_items := []
	for item in _items.values():
		server_items.push_back(inst2dict(item))
	
	var client_items := []
	for item in _items.values():
		client_items.push_back(_filter_client_properties(inst2dict(item)))
	
	var file := File.new()
	Log.ok(file.open_compressed("%s/items.sres" % dir, File.WRITE, File.COMPRESSION_ZSTD))
	file.store_var(server_items)
	file.close()
	
	file = File.new()
	Log.ok(file.open_compressed("%s/items.cres" % dir, File.WRITE, File.COMPRESSION_ZSTD))
	file.store_var(client_items)
	file.close()

