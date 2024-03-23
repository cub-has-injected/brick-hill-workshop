class_name Vector2Watcher
extends PropertyWatcher

func _init(in_target:Object, in_property:String).(in_target, in_property)->void :
	var scope = Profiler.scope(self, "_init(in_target: Object, in_property: String).", [in_target, in_property])

	pass

func get_control()->HBoxContainer:
	var scope = Profiler.scope(self, "get_control", [])

	var hbox:HBoxContainer = null

	if has_node("HBoxContainer"):
		hbox = $HBoxContainer
	else :
		var spinbox_x = BrickHillSpinBox.new()
		spinbox_x.name = "SpinBoxX"
		configure_spinbox(spinbox_x)
		spinbox_x.connect("value_changed", self, "set_vector2_property_component", [0])

		var spinbox_y = BrickHillSpinBox.new()
		spinbox_y.name = "SpinBoxY"
		configure_spinbox(spinbox_y)
		spinbox_y.connect("value_changed", self, "set_vector2_property_component", [1])

		hbox = HBoxContainer.new()
		hbox.name = "HBoxContainer"
		hbox.set("custom_constants/separation", 8)
		hbox.add_child(spinbox_x)
		hbox.add_child(spinbox_y)

		add_child(hbox)

	return hbox

func configure_spinbox(spinbox:SpinBox)->void :
	var scope = Profiler.scope(self, "configure_spinbox", [spinbox])

	spinbox.min_value = - 1024
	spinbox.max_value = 1024
	spinbox.step = 0.1
	spinbox.allow_greater = true
	spinbox.allow_lesser = true

	var line_edit = spinbox.get_line_edit()
	line_edit.connect("focus_entered", line_edit, "call_deferred", ["select_all"])
	line_edit.connect("focus_exited", line_edit, "call_deferred", ["deselect"])

func set_value(new_value)->void :
	var scope = Profiler.scope(self, "set_value", [new_value])

	if value != new_value:
		var control = get_control()
		var spin_box_x = control.get_node("SpinBoxX")
		var spin_box_y = control.get_node("SpinBoxY")

		spin_box_x.set_block_signals(true)
		spin_box_x.value = new_value.x
		spin_box_x.set_block_signals(false)

		spin_box_y.set_block_signals(true)
		spin_box_y.value = new_value.y
		spin_box_y.set_block_signals(false)
	.set_value(new_value)

func set_vector2_property_component(value:float, comp_index:int)->void :
	var scope = Profiler.scope(self, "set_vector2_property_component", [value:float, comp_index:int])

	var vector2 = target[property]
	vector2[comp_index] = value
	begin_set_target_property()
	set_target_property(vector2)
	end_set_target_property()
