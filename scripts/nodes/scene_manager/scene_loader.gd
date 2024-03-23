class_name WorkshopSceneLoader
extends Node

const CLASS_WHITELIST: = [
	SetRoot, 
	BrickHillEnvironmentGen, 
	BrickHillObject
]

signal scene_load_started()
signal populate_tree(scene_inst)
signal scene_load_finished()
signal scene_load_failed(title, message)

var scene_path:String
var dir = Directory.new()

func load_godot_scene(path:String)->void :
	var scope = Profiler.scope(self, "load_godot_scene", [path])

	var target_path = BrickHillUtil.get_temp_file_for_path(path)

	var copy_error = dir.copy(path, target_path)
	if copy_error:
		printerr(BrickHillUtil.get_error_string(copy_error))
		return 

	load_scn(target_path)

func load_scn(path:String)->void :
	var scope = Profiler.scope(self, "load_scn", [path])

	emit_signal("scene_load_started")

	var packed_scene_loader = ResourceLoader.load_interactive(path)
	while true:
		var result = packed_scene_loader.poll()
		match result:
			OK:
				pass
			ERR_FILE_EOF:
				break
			_:
				printerr("Error loading scene: %s" % [result])
				return 

		yield (get_tree(), "idle_frame")

	var packed_scene: = packed_scene_loader.get_resource() as PackedScene

	if not packed_scene:
		emit_signal("scene_load_failed", "Error", "Invalid scene file: Load failed")
		return 

	if validate_scene(packed_scene):
		var scene_inst = packed_scene.instance()
		if not scene_inst:
			emit_signal("scene_load_failed", "Error", "Invalid scene file: Instancing failed")
			return 

		scene_path = path

		var children = scene_inst.get_children()
		var child_idx = 0
		while true:
			var done: = false
			for i in range(0, 64):
				if not children[child_idx] is BrickHillEnvironmentGen:
					scene_inst.remove_child(children[child_idx])
				child_idx += 1
				if child_idx == children.size():
					done = true
					break
			if done:
				break

			yield (get_tree(), "idle_frame")

		emit_signal("populate_tree", scene_inst)

		child_idx = 0
		while true:
			var done: = false
			for i in range(0, 64):
				if not children[child_idx] is BrickHillEnvironmentGen:
					scene_inst.add_child(children[child_idx])
				child_idx += 1
				if child_idx == children.size():
					done = true
					break
			if done:
				break

			yield (get_tree(), "idle_frame")

		emit_signal("scene_load_finished")

func validate_scene(loaded_set_root:PackedScene)->bool:
	var scope = Profiler.scope(self, "validate_scene", [loaded_set_root])

	
	for variant in loaded_set_root._bundled.variants:
		if variant is GDScript:
			if variant.get_path().substr(0, 6) != "res://":
				emit_signal("scene_load_failed", "Error", "Invalid scene file: Foreign script detected")
				return false

	var scene_state = loaded_set_root.get_state()
	for i in range(0, scene_state.get_node_count()):
		var type = scene_state.get_node_type(i)

		
		if type != "Spatial":
			emit_signal("scene_load_failed", "Error", "Invalid scene file: Foreign node type detected")
			return false

		
		var found_script = false
		for p in range(0, scene_state.get_node_property_count(i)):
			var property = scene_state.get_node_property_name(i, p)
			if property == "script":
				found_script = true
				var value = scene_state.get_node_property_value(i, p)
				while true:
					if not value:
						emit_signal("scene_load_failed", "Error", "Invalid scene file: Illegal script assignment")
						return false

					if CLASS_WHITELIST.find(value) == - 1:
						value = value.get_base_script()
					else :
						break

		
		if not found_script:
			emit_signal("scene_load_failed", "Error", "Invalid scene file: Foreign node detected")
			return false

	
	
	

	return true
