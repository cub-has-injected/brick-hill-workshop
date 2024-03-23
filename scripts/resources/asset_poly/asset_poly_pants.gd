class_name AssetPolyPants
extends AssetPoly
tool 

export (Resource) var texture:Resource

func get_type_string()->String:
	var scope = Profiler.scope(self, "get_type_string", [])

	return "pants"

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	texture = AssetTexture.new()

	connect_subresources()

func connect_subresources()->void :
	var scope = Profiler.scope(self, "connect_subresources", [])

	if not texture.is_connected("changed", self, "on_changed"):
		texture.connect("changed", self, "on_changed")

func clear_asset()->void :
	var scope = Profiler.scope(self, "clear_asset", [])

	texture.asset_id = 0
	property_list_changed_notify()

func update_poly(poly:Dictionary)->void :
	var scope = Profiler.scope(self, "update_poly", [poly])

	texture.asset_id = poly.texture.lstrip("asset://").to_int()
