class_name AssetMesh
extends Asset
tool 

const BASE_DIR: = "user://assets/obj/"
const RESOURCE_EXTENSION: = "res"

export (ArrayMesh) var asset_obj:ArrayMesh

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	asset_obj = ArrayMesh.new()

	if not _dir.dir_exists(BASE_DIR):
		_dir.make_dir_recursive(BASE_DIR)

func load_obj(obj:ArrayMesh)->void :
	var scope = Profiler.scope(self, "load_obj", [obj])

	for i in range(0, obj.get_surface_count()):
		asset_obj.add_surface_from_arrays(obj.surface_get_primitive_type(i), obj.surface_get_arrays(i))
		yield (Engine.get_main_loop(), "idle_frame")

	emit_signal("changed")
	property_list_changed_notify()

func update_asset()->void :
	var scope = Profiler.scope(self, "update_asset", [])

	if asset_id == 0:
		clear_asset()
		return 

	var target_asset = "%s%s.%s" % [BASE_DIR, asset_id, RESOURCE_EXTENSION]
	print_debug("Checking cache for OBJ asset: %s" % [target_asset])
	if _dir.file_exists(target_asset):
		print_debug("Cache hit")
		var obj_loader = ResourceLoader.load_interactive(target_asset, "ArrayMesh")
		while true:
			yield (Engine.get_main_loop(), "idle_frame")
			var result = obj_loader.poll()
			if result == ERR_FILE_EOF:
				break

		var obj = obj_loader.get_resource() as ArrayMesh

		yield (Engine.get_main_loop(), "idle_frame")
		if obj:
			print_debug("Loaded OBJ: %s" % [obj])
			load_obj(obj)
			yield (Engine.get_main_loop(), "idle_frame")
			property_list_changed_notify()
			return 
	else :
		print_debug("Cache miss")
		pass



func request_success_callback(response_body:PoolByteArray, metadata:Dictionary)->void :
	var scope = Profiler.scope(self, "request_success_callback", [response_body, metadata])

	assert (metadata.asset_id != 0)

	var obj_string = response_body.get_string_from_ascii()

	var wavefront_obj = WavefrontObj.new()
	var wavefront_obj_mesh = WavefrontObjMesh.new()
	wavefront_obj_mesh.set_wavefront_obj(wavefront_obj)
	wavefront_obj.parse_obj_string(obj_string)
	yield (wavefront_obj_mesh, "build_complete")

	

	ResourceSaver.save("%s%s.%s" % [BASE_DIR, metadata.asset_id, RESOURCE_EXTENSION], wavefront_obj_mesh as ArrayMesh)

	yield (Engine.get_main_loop(), "idle_frame")

	if metadata.asset_id == asset_id:
		load_obj(wavefront_obj_mesh)
	else :
		clear_asset()

func clear_asset()->void :
	var scope = Profiler.scope(self, "clear_asset", [])

	for i in asset_obj.get_surface_count():
		asset_obj.surface_remove(0)

	emit_signal("changed")
