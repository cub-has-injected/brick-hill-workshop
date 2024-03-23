
class_name AssetPoly
extends Resource
tool 

const BASE_DIR: = "user://assets/"

export (int) var asset_id:int setget set_asset_id

var _dir:Directory

func set_asset_id(new_asset_id:int)->void :
	var scope = Profiler.scope(self, "set_asset_id", [new_asset_id])

	if asset_id != new_asset_id:
		asset_id = new_asset_id

		update_resource_name()
		if Engine.get_main_loop():
			update_asset()

func get_type_string()->String:
	var scope = Profiler.scope(self, "get_type_string", [])

	return ""

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	update_resource_name()

	_dir = Directory.new()
	_dir.open("user://")

func update_resource_name()->void :
	var scope = Profiler.scope(self, "update_resource_name", [])

	if asset_id == 0:
		resource_name = "Default Asset Poly"
	else :
		resource_name = "Asset Poly %s" % [asset_id]

func update_asset()->void :
	var scope = Profiler.scope(self, "update_asset", [])

	if asset_id == 0:
		clear_asset()
		return 

	var target_asset = "%s/%s.%s" % [BASE_DIR + get_type_string(), asset_id, "res"]
	print_debug("Checking cache for poly asset: %s" % [target_asset])
	if _dir.file_exists(target_asset):
		print_debug("Cache hit")
		var loader = ResourceLoader.load_interactive(target_asset)
		while true:
			yield (Engine.get_main_loop(), "idle_frame")
			var result = loader.poll()
			if result == ERR_FILE_EOF:
				break

		var asset = loader.get_resource() as AssetPolyData

		yield (Engine.get_main_loop(), "idle_frame")
		if is_instance_valid(asset):
			print_debug("Loaded poly asset: %s" % [asset.poly])
			update_poly(asset.poly)
			yield (Engine.get_main_loop(), "idle_frame")
			property_list_changed_notify()
			return 
	else :
		print_debug("Cache miss")
		pass



func clear_asset()->void :
	var scope = Profiler.scope(self, "clear_asset", [])

	pass

func request_success_callback(response_body:PoolByteArray, metadata:Dictionary)->void :
	var scope = Profiler.scope(self, "request_success_callback", [response_body, metadata])

	var response = response_body.get_string_from_ascii()
	var json = parse_json(response) as Array
	if not json:
		printerr("Failed to parse JSON")
		return 

	var json_poly = json[0]
	print(json_poly)

	if not "type" in json_poly:
		printerr("No type in response JSON")
		clear_asset()
		return 

	var type_string = get_type_string()
	if json_poly.type != type_string:
		printerr("Provided asset is not a %s" % [type_string])
		clear_asset()
		return 

	var asset_dir = BASE_DIR + get_type_string()
	var target_asset = "%s/%s.%s" % [asset_dir, asset_id, "res"]
	var res = AssetPolyData.new()
	res.poly = json_poly

	_dir.make_dir_recursive(asset_dir)
	ResourceSaver.save(target_asset, res as AssetPolyData)

	yield (Engine.get_main_loop(), "idle_frame")

	update_poly(json_poly)

func update_poly(poly:Dictionary)->void :
	var scope = Profiler.scope(self, "update_poly", [poly])

	pass

func request_failed_callback(error:String)->void :
	var scope = Profiler.scope(self, "request_failed_callback", [error])

	printerr("Failed to update asset poly: %s" % [error])
	clear_asset()

func connect_subresources()->void :
	var scope = Profiler.scope(self, "connect_subresources", [])

	pass

func disconnect_subresources()->void :
	var scope = Profiler.scope(self, "disconnect_subresources", [])

	pass

func on_changed():
	var scope = Profiler.scope(self, "on_changed", [])

	emit_signal("changed")
