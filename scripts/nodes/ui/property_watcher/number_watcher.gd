class_name NumberWatcher
extends PropertyWatcher

var integer = false
var spin_box:SpinBox = null

func _init(in_target:Object, in_property:String, in_integer:bool = false).(in_target, in_property)->void :
	var scope = Profiler.scope(self, "_init(in_target: Object, in_property: String, in_integer: bool = false).", [in_target, in_property])

	integer = in_integer

	for child in get_children():
		remove_child(child)
		child.queue_free()

	spin_box = BrickHillSpinBox.new()
	spin_box.size_flags_horizontal = SIZE_EXPAND_FILL
	spin_box.size_flags_vertical = SIZE_EXPAND_FILL
	if in_integer:
		spin_box.step = 1.0
	else :
		spin_box.step = 0.1
	spin_box.rounded = in_integer
	spin_box.connect("value_changed", self, "set_numeric_target_property")
	var line_edit = spin_box.get_line_edit()
	line_edit.connect("focus_entered", line_edit, "call_deferred", ["select_all"])
	line_edit.connect("focus_exited", line_edit, "call_deferred", ["deselect"])
	add_child(spin_box)

func set_value(new_value)->void :
	var scope = Profiler.scope(self, "set_value", [new_value])

	if value != new_value:
		spin_box.set_block_signals(true)
		spin_box.value = new_value
		spin_box.set_block_signals(false)
	.set_value(new_value)

func set_numeric_target_property(value:float):
	var scope = Profiler.scope(self, "set_numeric_target_property", [value])

	begin_set_target_property()
	if integer:
		set_target_property(int(value))
	else :
		set_target_property(value)
	end_set_target_property()
