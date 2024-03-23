class_name EngineVersionLabel
extends Label
tool 

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	text = Engine.get_version_info().string
