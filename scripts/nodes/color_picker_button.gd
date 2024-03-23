extends Button

func set_active_color(new_active_color:Color)->void :
	var scope = Profiler.scope(self, "set_active_color", [new_active_color])

	$Border / ActiveColor.set_frame_color(new_active_color)
