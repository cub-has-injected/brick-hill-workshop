class_name BrickHillSpinBox
extends SpinBox
tool 

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	theme = BrickHillResources.THEMES.workshop_general_spinbox
