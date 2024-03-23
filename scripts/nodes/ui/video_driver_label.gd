class_name VideoDriverLabel
extends Label
tool 

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	text = OS.get_video_driver_name(OS.get_current_video_driver())
