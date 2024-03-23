class_name ResourceChoiceWatcher
extends PropertyWatcher

var choices: = []

func _init(in_target:Object, in_property:String, in_choices:Array).(in_target, in_property)->void :
	var scope = Profiler.scope(self, "_init(in_target: Object, in_property: String, in_choices: Array).", [in_target, in_property])

	choices = in_choices
	get_menu_button()

func get_menu_button()->MenuButton:
	var scope = Profiler.scope(self, "get_menu_button", [])

	if choices.size() == 0:
		return null

	var menu_button:MenuButton = null

	if has_node("MenuButton"):
		menu_button = $MenuButton
	else :
		menu_button = MenuButton.new()
		menu_button.name = "MenuButton"
		menu_button.text = target[property].get_name()
		menu_button.flat = false
		menu_button.size_flags_horizontal = SIZE_EXPAND_FILL

		var popup = menu_button.get_popup()
		for choice in choices:
			popup.add_item(choice.get_name())
		popup.connect("index_pressed", self, "set_resource_choice_property", [menu_button])

		add_child(menu_button)

	return menu_button

func set_resource_choice_property(index:int, menu_button:MenuButton)->void :
	var scope = Profiler.scope(self, "set_resource_choice_property", [index, menu_button])

	menu_button.text = choices[index].get_name()
	begin_set_target_property()
	set_target_property(choices[index])
	end_set_target_property()

func set_value(new_value)->void :
	var scope = Profiler.scope(self, "set_value", [new_value])

	if value != new_value:
		var menu_button = get_menu_button()
		if menu_button:
			menu_button.set_block_signals(true)
			menu_button.text = new_value.get_name() if new_value else ""
			menu_button.set_block_signals(false)
	.set_value(new_value)
