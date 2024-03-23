
class_name Asset
extends Resource
tool 

export (int) var asset_id:int setget set_asset_id

var _dir:Directory

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	update_resource_name()

	_dir = Directory.new()
	_dir.open("user://")

func set_asset_id(new_asset_id:int)->void :
	var scope = Profiler.scope(self, "set_asset_id", [new_asset_id])

	if asset_id != new_asset_id:
		asset_id = new_asset_id

		update_resource_name()
		if Engine.get_main_loop():
			update_asset()

func update_resource_name()->void :
	var scope = Profiler.scope(self, "update_resource_name", [])

	if asset_id == 0:
		resource_name = "Default Asset"
	else :
		resource_name = "Asset %s" % [asset_id]

func update_asset()->void :
	var scope = Profiler.scope(self, "update_asset", [])

	pass

func clear_asset()->void :
	var scope = Profiler.scope(self, "clear_asset", [])

	pass

func request_success_callback(response_body:PoolByteArray, metadata:Dictionary)->void :
	var scope = Profiler.scope(self, "request_success_callback", [response_body, metadata])

	pass

func request_failed_callback(error:String)->void :
	var scope = Profiler.scope(self, "request_failed_callback", [error])

	printerr("Failed to update asset: %s" % [error])
	clear_asset()
