class_name CategoryLabel
extends VBoxContainer
tool 

export (String) var text setget set_text
export (Color) var separator_color = Color("b0b0b0") setget set_separator_color

var _label:Label = null
var _separator:ColorRect = null

func set_text(new_text:String)->void :
	var scope = Profiler.scope(self, "set_text", [new_text])

	if text != new_text:
		text = new_text
		if _label:
			_label.text = text

func set_separator_color(new_separator_color:Color)->void :
	var scope = Profiler.scope(self, "set_separator_color", [new_separator_color])

	if separator_color != new_separator_color:
		separator_color = new_separator_color
		if _separator:
			_separator.color = separator_color

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	set("custom_constants/separation", 2)

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	for child in get_children():
		if child.has_meta("category_label_child"):
			remove_child(child)
			child.queue_free()

	add_child(Control.new())

	_label = GroupLabel.new()
	_label.text = text
	_label.set_meta("category_label_child", true)
	add_child(_label)

	add_child(Control.new())

	_separator = ColorRect.new()
	_separator.size_flags_horizontal = SIZE_EXPAND_FILL
	_separator.size_flags_vertical = SIZE_SHRINK_END
	_separator.rect_min_size.y = 1
	_separator.color = separator_color
	_separator.set_meta("category_label_child", true)
	add_child(_separator)

