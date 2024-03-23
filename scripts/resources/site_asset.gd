class_name SiteAsset
extends Resource
tool 

const BASE_DIR: = "user://"
const PNG_DIR: = "assets/png/"
const OBJ_DIR: = "assets/obj/"
const RESOURCE_EXTENSION: = "res"

var asset_id:int setget set_asset_id
var asset_types:int setget set_asset_types

var asset_png:ImageTexture
var asset_obj:ArrayMesh

var _dir:Directory

func set_asset_types(new_asset_types:int)->void :
	var scope = Profiler.scope(self, "set_asset_types", [new_asset_types])

	if Engine.get_main_loop():
		if SiteAPI.AssetType.PNG & new_asset_types and not SiteAPI.AssetType.PNG & asset_types:
			update_asset(SiteAPI.AssetType.PNG)
		elif not SiteAPI.AssetType.PNG & new_asset_types and SiteAPI.AssetType.PNG & asset_types:
			clear_asset(SiteAPI.AssetType.PNG)

		if SiteAPI.AssetType.OBJ & new_asset_types and not SiteAPI.AssetType.OBJ & asset_types:
			update_asset(SiteAPI.AssetType.OBJ)
		elif not SiteAPI.AssetType.OBJ & new_asset_types and SiteAPI.AssetType.OBJ & asset_types:
			clear_asset(SiteAPI.AssetType.OBJ)

	if asset_types != new_asset_types:
		asset_types = new_asset_types
		property_list_changed_notify()

func set_asset_id(new_asset_id:int)->void :
	var scope = Profiler.scope(self, "set_asset_id", [new_asset_id])

	if asset_id != new_asset_id:
		asset_id = new_asset_id

		update_resource_name()
		update_assets()

func _get_property_list()->Array:
	var scope = Profiler.scope(self, "_get_property_list", [])

	var property_list: = []

	property_list.append({
		"name":"asset_id", 
		"type":TYPE_INT
	})

	property_list.append({
		"name":"asset_types", 
		"type":TYPE_INT, 
		"hint":PROPERTY_HINT_FLAGS, 
		"hint_string":"PNG,OBJ"
	})

	if SiteAPI.AssetType.PNG & asset_types:
		property_list.append({
			"name":"asset_png", 
			"type":TYPE_OBJECT, 
			"hint":PROPERTY_HINT_RESOURCE_TYPE, 
			"hint_string":"ImageTexture"
		})

	if SiteAPI.AssetType.OBJ & asset_types:
		property_list.append({
			"name":"asset_obj", 
			"type":TYPE_OBJECT, 
			"hint":PROPERTY_HINT_RESOURCE_TYPE, 
			"hint_string":"Resource"
		})

	return property_list

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	update_resource_name()

	asset_png = ImageTexture.new()
	asset_obj = ArrayMesh.new()

	_dir = Directory.new()
	_dir.open("user://")

	if not _dir.dir_exists(PNG_DIR):
		_dir.make_dir_recursive(PNG_DIR)

	if not _dir.dir_exists(OBJ_DIR):
		_dir.make_dir_recursive(OBJ_DIR)

func update_resource_name()->void :
	var scope = Profiler.scope(self, "update_resource_name", [])

	if asset_id == 0:
		resource_name = "Default Site Asset"
	else :
		resource_name = "Site Asset %s" % [asset_id]

func update_assets()->void :
	var scope = Profiler.scope(self, "update_assets", [])

	clear_asset(SiteAPI.AssetType.PNG)
	clear_asset(SiteAPI.AssetType.OBJ)

	if SiteAPI.AssetType.PNG & asset_types:
		update_asset(SiteAPI.AssetType.PNG)

	if SiteAPI.AssetType.OBJ & asset_types:
		update_asset(SiteAPI.AssetType.OBJ)

func clear_asset(asset_type:int)->void :
	var scope = Profiler.scope(self, "clear_asset", [asset_type])

	match asset_type:
		SiteAPI.AssetType.PNG:
			var image = Image.new()
			image.create(1, 1, false, Image.FORMAT_RGBA8)
			asset_png.create_from_image(image)
		SiteAPI.AssetType.OBJ:
			for i in asset_obj.get_surface_count():
				asset_obj.surface_remove(0)

func update_asset(asset_type:int)->void :
	var scope = Profiler.scope(self, "update_asset", [asset_type])

	if asset_id == 0:
		return 

	match asset_type:
		SiteAPI.AssetType.PNG:
			var target_asset = "%s%s.%s" % [PNG_DIR, asset_id, RESOURCE_EXTENSION]
			
			if _dir.file_exists(target_asset):
				
				var png_loader = ResourceLoader.load_interactive("%s%s" % [BASE_DIR, target_asset], "Image")
				while true:
					yield (Engine.get_main_loop(), "idle_frame")
					var result = png_loader.poll()
					if result == ERR_FILE_EOF:
						break

				var png = png_loader.get_resource() as Image
				yield (Engine.get_main_loop(), "idle_frame")
				if png:
					
					load_png(png)
					yield (Engine.get_main_loop(), "idle_frame")
					property_list_changed_notify()
					return 
			else :
				
				pass
		SiteAPI.AssetType.OBJ:
			var target_asset = "%s%s.%s" % [OBJ_DIR, asset_id, RESOURCE_EXTENSION]
			
			if _dir.file_exists(target_asset):
				
				var obj_loader = ResourceLoader.load_interactive("%s%s" % [BASE_DIR, target_asset], "ArrayMesh")
				while true:
					yield (Engine.get_main_loop(), "idle_frame")
					var result = obj_loader.poll()
					if result == ERR_FILE_EOF:
						break

				var obj = obj_loader.get_resource() as ArrayMesh

				yield (Engine.get_main_loop(), "idle_frame")
				if obj:
					
					load_obj(obj)
					yield (Engine.get_main_loop(), "idle_frame")
					property_list_changed_notify()
					return 
			else :
				
				pass

	var success_callback:String
	match asset_type:
		SiteAPI.AssetType.PNG:
			success_callback = "asset_png_callback"
		SiteAPI.AssetType.OBJ:
			success_callback = "asset_obj_callback"

	HTTPManager.queue_get(
		SiteAPI.HOST_API, 
		SiteAPI.get_retrieve_asset_endpoint(asset_id, asset_type), 
		[], 
		funcref(self, success_callback), 
		funcref(self, "request_failed_callback"), 
		null, 
		{"asset_id":asset_id}
	)



func asset_png_callback(response_body:PoolByteArray, metadata:Dictionary)->void :
	var scope = Profiler.scope(self, "asset_png_callback", [response_body, metadata])

	assert (metadata.asset_id != 0)
	var png_image = Image.new()
	png_image.load_png_from_buffer(response_body)

	yield (Engine.get_main_loop(), "idle_frame")

	if png_image.get_format() != Image.FORMAT_RGBA8:
		png_image.convert(Image.FORMAT_RGBA8)
		yield (Engine.get_main_loop(), "idle_frame")

	ResourceSaver.save("%s%s%s.%s" % [BASE_DIR, PNG_DIR, metadata.asset_id, RESOURCE_EXTENSION], png_image)

	yield (Engine.get_main_loop(), "idle_frame")

	if metadata.asset_id == asset_id:
		load_png(png_image)
	else :
		clear_asset(SiteAPI.AssetType.PNG)

func asset_obj_callback(response_body:PoolByteArray, metadata:Dictionary)->void :
	var scope = Profiler.scope(self, "asset_obj_callback", [response_body, metadata])

	assert (metadata.asset_id != 0)

	var obj_string = response_body.get_string_from_ascii()

	var wavefront_obj = WavefrontObj.new()
	var wavefront_obj_mesh = WavefrontObjMesh.new()
	wavefront_obj_mesh.set_wavefront_obj(wavefront_obj)
	wavefront_obj.parse_obj_string(obj_string)
	yield (wavefront_obj_mesh, "build_complete")

	

	ResourceSaver.save("%s%s%s.%s" % [BASE_DIR, OBJ_DIR, metadata.asset_id, RESOURCE_EXTENSION], wavefront_obj_mesh as ArrayMesh)

	yield (Engine.get_main_loop(), "idle_frame")

	if metadata.asset_id == asset_id:
		load_obj(wavefront_obj_mesh)
	else :
		clear_asset(SiteAPI.AssetType.OBJ)

func request_failed_callback(error:String)->void :
	var scope = Profiler.scope(self, "request_failed_callback", [error])

	printerr("Failed to update site asset: %s" % [error])
	clear_asset(SiteAPI.AssetType.PNG)
	clear_asset(SiteAPI.AssetType.OBJ)

func load_png(png:Image)->void :
	var scope = Profiler.scope(self, "load_png", [png])

	asset_png.create_from_image(png, ImageTexture.FLAG_MIPMAPS | ImageTexture.FLAG_REPEAT | ImageTexture.FLAG_FILTER | ImageTexture.FLAG_ANISOTROPIC_FILTER | ImageTexture.FLAG_CONVERT_TO_LINEAR)

func load_obj(obj:ArrayMesh)->void :
	var scope = Profiler.scope(self, "load_obj", [obj])

	for i in range(0, obj.get_surface_count()):
		asset_obj.add_surface_from_arrays(obj.surface_get_primitive_type(i), obj.surface_get_arrays(i))
		yield (Engine.get_main_loop(), "idle_frame")
	property_list_changed_notify()
