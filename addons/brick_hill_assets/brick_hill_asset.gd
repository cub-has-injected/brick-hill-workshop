class_name BrickHillAsset
extends Reference

signal loaded()

var _id:int setget , get_id
var _load_progress:float setget , get_load_progress

func get_id()->int:
	var scope = Profiler.scope(self, "get_id", [])

	return _id

func get_load_progress()->float:
	var scope = Profiler.scope(self, "get_load_progress", [])	
	return 100.0
#	return BrickHillAssets.get_asset_load_progress(String(_id))

func is_loaded()->bool:
	var scope = Profiler.scope(self, "is_loaded", [])

	return get_load_progress() == 1.0

func get_asset():
	var scope = Profiler.scope(self, "get_asset", [])

	#return yield (BrickHillAssets.get_asset(String(_id)), "completed")

func _init(in_id:int, lazy:bool = false)->void :
	var scope = Profiler.scope(self, "_init", [in_id, lazy])

	_id = in_id

	#BrickHillAssets.connect("asset_loaded", self, "on_asset_loaded")

#	if not lazy:
#		yield (BrickHillAssets.get_asset(String(_id)), "completed")

func on_asset_loaded(asset_id:String)->void :
	var scope = Profiler.scope(self, "on_asset_loaded", [asset_id])

	if String(_id) == asset_id:
		emit_signal("loaded")
