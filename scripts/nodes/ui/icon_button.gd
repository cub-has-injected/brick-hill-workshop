extends Button
tool 

export (Texture) var button_icon setget set_button_icon
export (Texture) var pressed_icon

var texture_rect:TextureRect

func set_button_icon(new_button_icon:Texture)->void :
	var scope = Profiler.scope(self, "set_button_icon", [new_button_icon])

	if button_icon != new_button_icon:
		button_icon = new_button_icon
		if is_inside_tree():
			update_press_release(false)

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	connect("button_down", self, "update_press_release", [true])
	connect("button_up", self, "update_press_release", [false])
	connect("toggled", self, "update_toggle")

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	for child in get_children():
		if child.has_meta("icon_button_child"):
			child.set_meta("icon_button_child", true)

	texture_rect = TextureRect.new()
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	texture_rect.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	add_child(texture_rect)

	if pressed:
		apply_pressed_icon()
	else :
		apply_default_icon()

func update_press_release(down:bool)->void :
	var scope = Profiler.scope(self, "update_press_release", [down])

	if toggle_mode:
		return 

	if down:
		apply_pressed_icon()
	else :
		apply_default_icon()

func update_toggle(toggled:bool)->void :
	var scope = Profiler.scope(self, "update_toggle", [toggled])

	if not toggle_mode:
		return 

	if toggled:
		apply_pressed_icon()
	else :
		apply_default_icon()

func apply_default_icon()->void :
	var scope = Profiler.scope(self, "apply_default_icon", [])

	texture_rect.texture = button_icon

func apply_pressed_icon()->void :
	var scope = Profiler.scope(self, "apply_pressed_icon", [])

	texture_rect.texture = pressed_icon
