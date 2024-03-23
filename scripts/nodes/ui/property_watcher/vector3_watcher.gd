class_name Vector3Watcher
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
		spinbox_x.connect("value_changed", self, "set_vector3_property_component", [0])

		var spinbox_y = BrickHillSpinBox.new()
		spinbox_y.name = "SpinBoxY"
		configure_spinbox(spinbox_y)
		spinbox_y.connect("value_changed", self, "set_vector3_property_component", [1])

		var spinbox_z = BrickHillSpinBox.new()
		spinbox_z.name = "SpinBoxZ"
		configure_spinbox(spinbox_z)
		spinbox_z.connect("value_changed", self, "set_vector3_property_component", [2])

		hbox = HBoxContainer.new()
		hbox.name = "HBoxContainer"
		hbox.set("custom_constants/separation", 8)
		hbox.add_child(spinbox_x)
		hbox.add_child(spinbox_y)
		hbox.add_child(spinbox_z)

		add_child(hbox)

	return hbox

func configure_spinbox(spinbox:SpinBox)->void :
	var scope = Profiler.scope(self, "configure_spinbox", [spinbox])

	spinbox.min_value = - 100
	spinbox.max_value = 100
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
		var spin_box_z = control.get_node("SpinBoxZ")

		spin_box_x.set_block_signals(true)
		spin_box_x.value = new_value.x
		spin_box_x.set_block_signals(false)

		spin_box_y.set_block_signals(true)
		spin_box_y.value = new_value.y
		spin_box_y.set_block_signals(false)

		spin_box_z.set_block_signals(true)
		spin_box_z.value = new_value.z
		spin_box_z.set_block_signals(false)
	.set_value(new_value)

func set_vector3_property_component(value:float, comp_index:int)->void :
	var scope = Profiler.scope(self, "set_vector3_property_component", [value, comp_index])

	var vector3 = target[property]
	vector3[comp_index] = value
	begin_set_target_property()
	set_target_property(vector3)
	end_set_target_property()
