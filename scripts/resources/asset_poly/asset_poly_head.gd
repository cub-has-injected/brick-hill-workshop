class_name AssetPolyHead
extends AssetPoly
tool 

export (Resource) var mesh:Resource
export (Resource) var texture:Resource

func get_type_string()->String:
	var scope = Profiler.scope(self, "get_type_string", [])

	return "head"

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	mesh = AssetMesh.new()
	texture = AssetTexture.new()

	connect_subresources()

func connect_subresources()->void :
	var scope = Profiler.scope(self, "connect_subresources", [])

	if not mesh.is_connected("changed", self, "on_changed"):
		mesh.connect("changed", self, "on_changed")

	if not texture.is_connected("changed", self, "on_changed"):
		texture.connect("changed", self, "on_changed")

func clear_asset()->void :
	var scope = Profiler.scope(self, "clear_asset", [])

	mesh.asset_id = 0
	texture.asset_id = 0
	property_list_changed_notify()

func update_poly(poly:Dictionary)->void :
	var scope = Profiler.scope(self, "update_poly", [poly])

	mesh.asset_id = poly.mesh.to_int()
	if "texture" in poly:
		texture.asset_id = poly.texture.to_int()
	else :
		texture.asset_id = 0
