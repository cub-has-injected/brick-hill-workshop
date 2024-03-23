class_name GroupLabel
extends InspectorLabel
tool 

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	._init()
	add_font_override("font", BrickHillResources.FONTS.regular)
