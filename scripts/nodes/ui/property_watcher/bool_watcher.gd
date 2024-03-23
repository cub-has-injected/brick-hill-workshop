class_name BoolWatcher
extends PropertyWatcher

func _init(in_target:Object, in_property:String).(in_target, in_property)->void :
	pass

func get_checkbox()->CheckBox:
	var checkbox:CheckBox = null

	if has_node("CheckBox"):
		checkbox = $CheckBox
	else :
		checkbox = CheckBox.new()
		checkbox.name = "CheckBox"
		checkbox.flat = true
		checkbox.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		checkbox.connect("toggled", self, "set_bool_target_property")
		add_child(checkbox)

	return checkbox

func set_bool_target_property(value:bool)->void :
	begin_set_target_property()
	set_target_property(value)
	end_set_target_property()

func set_value(new_value)->void :
	if value != new_value:
		var checkbox = get_checkbox()
		checkbox.set_block_signals(true)
		checkbox.pressed = new_value
		checkbox.set_block_signals(false)
	.set_value(new_value)
