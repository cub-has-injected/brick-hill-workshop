class_name GameVersionLabel
extends Label

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	text = "(" + Version.STRING + ")"
