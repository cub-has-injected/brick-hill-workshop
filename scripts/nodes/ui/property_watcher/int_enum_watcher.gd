class_name IntEnumWatcher
extends PropertyWatcher

var choices: = PoolStringArray()
var option_button:OptionButton = null

func _init(in_target:Object, in_property:String, in_choices:PoolStringArray).(in_target, in_property)->void :
	var scope = Profiler.scope(self, "_init(in_target: Object, in_property: String, in_choices: PoolStringArray).", [in_target, in_property])

	choices = in_choices

	for child in get_children():
		remove_child(child)
		child.queue_free()

	option_button = OptionButton.new()
	for choice in choices:
		option_button.add_item(choice)
	add_child(option_button)
	option_button.connect("item_selected", self, "set_int_target_property")

func set_value(new_value)->void :
	var scope = Profiler.scope(self, "set_value", [new_value])

	if value != new_value:
		option_button.set_block_signals(true)
		option_button.selected = new_value
		option_button.set_block_signals(false)
	.set_value(new_value)

func set_int_target_property(value:int):
	var scope = Profiler.scope(self, "set_int_target_property", [value])

	begin_set_target_property()
	set_target_property(value)
	end_set_target_property()
