class_name EnumButton
extends Button
tool 

signal pressed_enum(value)

export (Texture) var button_icon:Texture setget set_button_icon
export (int) var value:int

func set_button_icon(new_button_icon:Texture)->void :
	var scope = Profiler.scope(self, "set_button_icon", [new_button_icon])

	if button_icon != new_button_icon:
		button_icon = new_button_icon
		update_button_icon()

func update_button_icon()->void :
	var scope = Profiler.scope(self, "update_button_icon", [])

	var icon = $Clip / Icon as TextureRect
	icon.texture = button_icon

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	update_button_icon()
	connect("pressed", self, "handle_pressed")

func handle_pressed()->void :
	var scope = Profiler.scope(self, "handle_pressed", [])

	emit_signal("pressed_enum", value)
