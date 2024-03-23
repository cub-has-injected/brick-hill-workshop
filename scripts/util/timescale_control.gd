extends Node

func _input(event:InputEvent)->void :
	var scope = Profiler.scope(self, "_input", [event])

	if not OS.is_debug_build():
		return 

	if event.is_echo():
		return 

	if event is InputEventKey:
		match event.scancode:
			KEY_KP_0:
				Engine.time_scale = 1.0
			KEY_KP_1:
				Engine.time_scale = 0.1
			KEY_KP_2:
				Engine.time_scale = 0.2
			KEY_KP_3:
				Engine.time_scale = 0.3
			KEY_KP_4:
				Engine.time_scale = 0.4
			KEY_KP_5:
				Engine.time_scale = 0.5
			KEY_KP_6:
				Engine.time_scale = 0.6
			KEY_KP_7:
				Engine.time_scale = 0.7
			KEY_KP_8:
				Engine.time_scale = 0.8
			KEY_KP_9:
				Engine.time_scale = 0.9
