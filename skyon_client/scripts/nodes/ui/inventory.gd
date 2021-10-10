extends Control

const SLOT_ROW_COUNT: int = 8
const SLOT: Resource = preload("res://scenes/components/ui/item_slot.tscn")

onready var _mid_container: VBoxContainer = $BG/V/SC/Mid

func _ready():
	set_slot_count(50)
	pass

func set_slot_count(count: int) -> void:
	Log.d("Initializing inventory with %d slots" % count)
	
	for child in _mid_container.get_children():
		child.queue_free()
	
	var row_count := count / SLOT_ROW_COUNT
	var last_row_slot_count := count % SLOT_ROW_COUNT
	
	for i in range(row_count + 1):
		var hbox := HBoxContainer.new()
		hbox.name = "R%d" % [i]
		hbox.size_flags_horizontal = SIZE_EXPAND
		
		_mid_container.add_child(hbox)
		
		var slot_count := last_row_slot_count if i == row_count else SLOT_ROW_COUNT
		
		for k in range(slot_count):
			var slot := SLOT.instance()
			slot.name = k as String
			hbox.add_child(slot)


func _on_CloseBtn_pressed():
	Systems.ui.close_window(Systems.ui.Window.INVENTORY)
