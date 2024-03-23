class_name StringWatcher
extends PropertyWatcher

var _line_edit:LineEdit = null

func _init(in_target:Object, in_property:String).(in_target, in_property)->void :
	var scope = Profiler.scope(self, "_init(in_target: Object, in_property: String).", [in_target, in_property])

	for child in get_children():
		remove_child(child)
		child.queue_free()

	_line_edit = LineEdit.new()
	_line_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	_line_edit.size_flags_vertical = SIZE_EXPAND_FILL
	_line_edit.connect("text_changed", self, "set_string_target_property")
	_line_edit.connect("focus_entered", _line_edit, "call_deferred", ["select_all"])
	_line_edit.connect("focus_exited", _line_edit, "call_deferred", ["deselect"])
	add_child(_line_edit)

func set_value(new_value)->void :
	var scope = Profiler.scope(self, "set_value", [new_value])

	if value != new_value:
		_line_edit.set_block_signals(true)
		var cached_cursor_position = _line_edit.get_cursor_position()
		_line_edit.text = new_value
		_line_edit.set_cursor_position(cached_cursor_position)
		_line_edit.set_block_signals(false)
	.set_value(new_value)

func set_string_target_property(value:String):
	var scope = Profiler.scope(self, "set_string_target_property", [value])

	begin_set_target_property()
	set_target_property(value)
	end_set_target_property()
