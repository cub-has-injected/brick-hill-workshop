class_name ColorWatcher
extends PropertyWatcher

func _init(in_target:Object, in_property:String).(in_target, in_property)->void :
	var scope = Profiler.scope(self, "_init(in_target: Object, in_property: String).", [in_target, in_property])

	pass

func get_color_picker_control()->Control:
	var scope = Profiler.scope(self, "get_color_picker_control", [])

	var color_picker_control:Control = null

	if has_node("ColorPicker"):
		color_picker_control = $ColorPicker
	else :
		var color_picker_button = ColorPickerButton.new()
		color_picker_button.anchor_right = 1
		color_picker_button.anchor_bottom = 1
		color_picker_button.margin_top = 1
		color_picker_button.margin_left = 1
		color_picker_button.margin_right = - 1
		color_picker_button.margin_bottom = - 1

		color_picker_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		color_picker_button.name = "ColorPickerButton"
		color_picker_button.connect("color_changed", self, "set_color_target_property")

		color_picker_control = ColorRect.new()
		color_picker_control.color = Color.black
		color_picker_control.name = "ColorPicker"
		color_picker_control.add_child(color_picker_button)

		add_child(color_picker_control)

	return color_picker_control

var started = false
func _input(event:InputEvent)->void :
	var scope = Profiler.scope(self, "_input", [event])

	if event is InputEventMouseButton:
		if started and not BUTTON_LEFT & event.button_mask == BUTTON_LEFT:
			end_set_target_property()
			started = false

func set_color_target_property(value:Color):
	var scope = Profiler.scope(self, "set_color_target_property", [value])

	var mouse_position = get_viewport().get_mouse_position()
	var picker = get_color_picker_control().get_node("ColorPickerButton").get_picker()
	var picker_rect = Rect2(picker.rect_global_position, picker.rect_size)

	if not picker_rect.has_point(mouse_position):
		return 

	if not started:
		begin_set_target_property()
		started = true

	set_target_property(value)


func set_value(new_value)->void :
	var scope = Profiler.scope(self, "set_value", [new_value])

	if value != new_value:
		var color_picker_button = get_color_picker_control().get_node("ColorPickerButton")
		color_picker_button.set_block_signals(true)
		color_picker_button.color = new_value
		color_picker_button.set_block_signals(false)
	.set_value(new_value)
