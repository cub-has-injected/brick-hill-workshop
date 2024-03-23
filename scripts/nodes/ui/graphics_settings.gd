extends MarginContainer
tool 

var vbox:VBoxContainer = null

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	for child in get_children():
		if child.has_meta("graphics_settings_child"):
			remove_child(child)
			child.queue_free()

	vbox = VBoxContainer.new()
	vbox.set_anchors_and_margins_preset(PRESET_WIDE)
	vbox.set("custom_constants/separation", 8)
	vbox.set_meta("graphics_settings_child", true)

	add_child(vbox)

func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	for entry in GraphicsSettings.data.get_graphics_settings():
		var hbox = HBoxContainer.new()
		if "description" in entry:
			hbox.hint_tooltip = entry.description
		hbox.size_flags_horizontal = SIZE_EXPAND_FILL

		var label = Label.new()
		label.text = entry.display_name
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		hbox.add_child(label)

		var control = create_entry_control(entry)
		update_entry_control(control, entry)
		if control:
			control.size_flags_horizontal = SIZE_EXPAND_FILL
			hbox.add_child(control)

		if not control:
			label.set("custom_fonts/font", preload("res://resources/dynamic_font/montserrat_regular.tres"))

		vbox.add_child(hbox)

	GraphicsSettings.data.connect("preset_changed", self, "update_entry_controls")

func update_entry_controls()->void :
	var scope = Profiler.scope(self, "update_entry_controls", [])

	var graphics_settings = GraphicsSettings.data.get_graphics_settings()
	for i in range(0, graphics_settings.size()):
		var entry = graphics_settings[i]
		if vbox.get_child(i).get_child_count() > 1:
			var control = vbox.get_child(i).get_child(1)
			update_entry_control(control, entry)


func create_entry_control(entry:Dictionary)->Control:
	var scope = Profiler.scope(self, "create_entry_control", [entry])

	var hints = []
	if "hint_string" in entry:
		hints = entry.hint_string.split(",")

	var callback = ""
	if "callback" in entry:
		callback = entry.callback

	var control = null
	match entry.type:
		TYPE_BOOL:
			control = CheckBox.new()
			control.flat = true
			control.pressed = GraphicsSettings.data[entry.name]
			control.connect("toggled", GraphicsSettings.data, callback, [true])
		TYPE_INT:
			match entry.hint:
				PROPERTY_HINT_RANGE:
					var label = Label.new()
					label.text = String(GraphicsSettings.data[entry.name])
					label.rect_min_size.x = 40

					var slider = HSlider.new()
					slider.min_value = hints[0].to_float()
					slider.max_value = hints[1].to_float()
					slider.step = hints[2].to_float()
					slider.value = GraphicsSettings.data[entry.name]
					slider.size_flags_horizontal = SIZE_EXPAND_FILL
					slider.connect("value_changed", GraphicsSettings.data, callback, [true])
					slider.connect("value_changed", self, "range_slider_changed", [label, slider])

					control = HBoxContainer.new()
					control.add_child(label)
					control.add_child(slider)
				PROPERTY_HINT_ENUM:
					control = OptionButton.new()
					for hint in hints:
						control.add_item(hint)
					control.selected = GraphicsSettings.data[entry.name]
					control.connect("item_selected", GraphicsSettings.data, callback, [true])
		TYPE_REAL:
			match entry.hint:
				PROPERTY_HINT_RANGE:
					var label = Label.new()
					label.text = String(GraphicsSettings.data[entry.name])
					label.rect_min_size.x = 40

					var slider = HSlider.new()
					slider.min_value = hints[0].to_float()
					slider.max_value = hints[1].to_float()
					slider.step = hints[2].to_float()
					slider.value = GraphicsSettings.data[entry.name]
					slider.size_flags_horizontal = SIZE_EXPAND_FILL
					slider.connect("value_changed", GraphicsSettings.data, callback, [true])
					slider.connect("value_changed", self, "range_slider_changed", [label, slider])

					control = HBoxContainer.new()
					control.add_child(label)
					control.add_child(slider)

	return control

func update_entry_control(control:Control, entry:Dictionary)->void :
	var scope = Profiler.scope(self, "update_entry_control", [control, entry])

	match entry.type:
		TYPE_BOOL:
			control.pressed = GraphicsSettings.data[entry.name]
		TYPE_INT:
			match entry.hint:
				PROPERTY_HINT_ENUM:
					control.selected = GraphicsSettings.data[entry.name]
		TYPE_REAL:
			match entry.hint:
				PROPERTY_HINT_RANGE:
					control.get_child(1).value = GraphicsSettings.data[entry.name]

func range_slider_changed(_value:float, label:Label, slider:Slider)->void :
	var scope = Profiler.scope(self, "range_slider_changed", [_value, label, slider])

	label.text = String(slider.value)
