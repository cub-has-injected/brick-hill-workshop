class_name SceneLoader
extends Node
tool 

export (PackedScene) var packed_scene setget set_packed_scene

var _instance:Node

func set_packed_scene(new_packed_scene:PackedScene)->void :
	var scope = Profiler.scope(self, "set_packed_scene", [new_packed_scene])

	if packed_scene != new_packed_scene:
		try_unload_scene()
		packed_scene = new_packed_scene
		try_load_scene()

func try_unload_scene()->void :
	var scope = Profiler.scope(self, "try_unload_scene", [])

	if _instance:
		remove_child(_instance)
		_instance.queue_free()

func try_load_scene()->void :
	var scope = Profiler.scope(self, "try_load_scene", [])

	if packed_scene:
		_instance = packed_scene.instance()
		if _instance:
			var script = _instance.get_script()
			if script and script.has_script_signal("load_scene"):
				_instance.connect("load_scene", self, "set_packed_scene")

		add_child(_instance)
