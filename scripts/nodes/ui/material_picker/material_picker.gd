class_name MaterialPicker
extends HBoxContainer
tool 

signal pressed()
signal released()
signal pressed_enum(value)

export (int) var selected_index:int setget set_selected_index
export (bool) var disabled: = false setget set_disabled
var button_group:ButtonGroup

func set_selected_index(new_selected_index:int)->void :
	var scope = Profiler.scope(self, "set_selected_index", [new_selected_index])

	assert (new_selected_index < get_child_count())
	if selected_index != new_selected_index:
		selected_index = new_selected_index

		if is_inside_tree():
			update_selected_index()

func set_disabled(new_disabled:bool)->void :
	var scope = Profiler.scope(self, "set_disabled", [new_disabled])

	for child in get_children():
		child.propagate_call("set_disabled", [new_disabled], true)

func update_selected_index()->void :
	var scope = Profiler.scope(self, "update_selected_index", [])

	for child in get_children():
		if child.value == selected_index:
			child.pressed = true
			break

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	button_group = ButtonGroup.new()
	button_group.resource_name = "Material Picker"
	set("custom_constants/separation", 8)

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	for child in get_children():
		if child.has_meta("surface_picker_child"):
			BrickHillUtil.disconnect_checked(child, "pressed", self, "pressed")
			BrickHillUtil.disconnect_checked(child, "button_up", self, "released")
			BrickHillUtil.disconnect_checked(child, "pressed_enum", self, "pressed_enum")
			remove_child(child)
			child.queue_free()

	for i in range(0, BrickHillResources.MATERIAL_ALBEDO_TEXTURES.size()):
		var key = BrickHillResources.MATERIAL_ALBEDO_TEXTURES.keys()[i]
		var texture = BrickHillResources.MATERIAL_ALBEDO_TEXTURES[key]
		var enum_scene: = preload("res://scenes/instanced/workshop/EnumButton.tscn") as PackedScene
		var enum_button = enum_scene.instance()
		enum_button.button_icon = texture
		enum_button.hint_tooltip = key.capitalize()
		enum_button.value = i
		enum_button.toggle_mode = true
		enum_button.group = button_group
		enum_button.action_mode = Button.ACTION_MODE_BUTTON_PRESS
		enum_button.focus_mode = FOCUS_NONE
		enum_button.pressed = i == 0
		enum_button.set_meta("surface_picker_child", true)
		BrickHillUtil.connect_checked(enum_button, "pressed", self, "pressed", [])
		BrickHillUtil.connect_checked(enum_button, "button_up", self, "released", [])
		BrickHillUtil.connect_checked(enum_button, "pressed_enum", self, "pressed_enum", [])
		add_child(enum_button)

	update_selected_index()

func pressed()->void :
	var scope = Profiler.scope(self, "pressed", [])

	emit_signal("pressed")

func released()->void :
	var scope = Profiler.scope(self, "released", [])

	emit_signal("released")

func pressed_enum(value:int)->void :
	var scope = Profiler.scope(self, "pressed_enum", [value])

	emit_signal("pressed_enum", value)
