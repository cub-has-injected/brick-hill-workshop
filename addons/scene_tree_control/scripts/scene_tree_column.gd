class_name SceneTreeColumn
extends Resource
tool 

enum Mode{
	STRING = 0, 
	CHECK = 1, 
	RANGE = 2, 
	ICON = 3, 
	CUSTOM = 4
}

export (Mode) var mode = Mode.STRING
export (String) var title setget set_title
export (String) var getter
export (String) var setter
export (int) var min_width: = 1
export (bool) var expand: = true
export (bool) var editable: = true
export (bool) var selectable: = true

export (bool) var custom_as_button: = false
export (Color) var custom_bg_color: = Color.black
export (Color) var custom_color: = Color.white
export (Script) var custom_control

func set_title(new_title:String)->void :
	var scope = Profiler.scope(self, "set_title", [new_title])

	if title != new_title:
		title = new_title
		set_name(title)

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	set_name("Scene Tree Column")
