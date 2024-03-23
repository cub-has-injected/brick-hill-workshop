class_name SidebarTabHeader
extends Control
tool 

signal close_pressed()

export (String) var title = "Sidebar Header"
export (Font) var font = null
export (bool) var show_button: = true

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	for child in get_children():
		remove_child(child)
		child.queue_free()

	var panel = Panel.new()
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color("f0f0f0")
	panel.set("custom_styles/panel", panel_style)
	panel.set_anchors_and_margins_preset(PRESET_WIDE)

	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_margins_preset(PRESET_WIDE)
	hbox.size_flags_horizontal = SIZE_EXPAND_FILL
	hbox.size_flags_vertical = SIZE_EXPAND_FILL
	panel.add_child(hbox)

	var margin_container = MarginContainer.new()
	margin_container.size_flags_horizontal = SIZE_EXPAND_FILL
	margin_container.size_flags_vertical = SIZE_EXPAND_FILL
	margin_container.set("custom_constants/margin_left", 8)
	hbox.add_child(margin_container)

	var label = Label.new()
	label.text = title
	if font:
		label.set("custom_fonts/font", font)
	margin_container.add_child(label)

	if show_button:
		var close_button = Button.new()
		close_button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		close_button.rect_min_size = Vector2(40, 40)
		close_button.connect("pressed", self, "close_pressed")

		var close_icon = TextureRect.new()
		close_icon.texture = preload("res://ui/icons/workshop-assets/controls/menuclose.png")
		close_icon.set_anchors_and_margins_preset(Control.PRESET_WIDE)
		close_icon.expand = true
		close_icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		close_button.add_child(close_icon)

		hbox.add_child(close_button)

	add_child(panel)

func close_pressed()->void :
	var scope = Profiler.scope(self, "close_pressed", [])

	emit_signal("close_pressed")
