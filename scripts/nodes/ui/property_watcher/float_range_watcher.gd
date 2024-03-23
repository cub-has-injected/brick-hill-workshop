class_name FloatRangeWatcher
extends PropertyWatcher

const USE_SPIN_BOX: = true

var min_value = 0
var max_value = 1
var step_value = 0

var spin_box:SpinBox = null
var slider:HSlider = null
var label:Label = null

func _init(in_target:Object, in_property:String, in_min_value:float, in_max_value:float, in_step_value:float).(in_target, in_property)->void :
	var scope = Profiler.scope(self, "_init(in_target: Object, in_property: String, in_min_value: float, in_max_value: float, in_step_value: float).", [in_target, in_property])

	min_value = in_min_value
	max_value = in_max_value
	step_value = in_step_value

	for child in get_children():
		remove_child(child)
		child.queue_free()

	if USE_SPIN_BOX:
		spin_box = BrickHillSpinBox.new()
		
		spin_box.size_flags_vertical = SIZE_EXPAND_FILL
		spin_box.min_value = min_value
		spin_box.max_value = max_value
		spin_box.step = step_value
		spin_box.connect("value_changed", self, "set_float_target_property")

		var line_edit = spin_box.get_line_edit()
		line_edit.connect("focus_entered", line_edit, "call_deferred", ["select_all"])
		line_edit.connect("focus_exited", line_edit, "call_deferred", ["deselect"])

	slider = HSlider.new()
	slider.size_flags_horizontal = SIZE_EXPAND_FILL
	slider.size_flags_vertical = SIZE_EXPAND_FILL
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step_value
	slider.connect("value_changed", self, "set_float_target_property")

	var padding = Control.new()
	padding.rect_min_size.x = 8

	label = Label.new()
	label.rect_min_size.x = 48
	label.rect_size.x = 48
	label.align = Label.ALIGN_RIGHT

	var hbox = HBoxContainer.new()
	hbox.add_child(slider)
	hbox.add_child(padding)
	if USE_SPIN_BOX:
		hbox.add_child(spin_box)
	else :
		hbox.add_child(label)

	add_child(hbox)

func set_value(new_value)->void :
	var scope = Profiler.scope(self, "set_value", [new_value])

	if value != new_value:
		if USE_SPIN_BOX:
			spin_box.set_block_signals(true)
			spin_box.value = new_value
			spin_box.set_block_signals(false)

		slider.set_block_signals(true)
		slider.value = new_value
		slider.set_block_signals(false)

		var foo = String(new_value)
		var bar = foo.split(".")
		var dig = bar[0].length()
		var dec = 0
		if bar.size() > 1:
			dec = max(0, 3 - dig)
		label.text = String(new_value).pad_decimals(dec)
	.set_value(new_value)

var started = false
func _input(event:InputEvent)->void :
	var scope = Profiler.scope(self, "_input", [event])

	if event is InputEventMouseButton:
		if started and not BUTTON_LEFT & event.button_mask == BUTTON_LEFT:
			end_set_target_property()
			started = false

func set_float_target_property(value:float):
	var scope = Profiler.scope(self, "set_float_target_property", [value])

	if not started:
		begin_set_target_property()
		started = true

	set_target_property(value)
