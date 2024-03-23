class_name AssetPolyFigure
extends AssetPoly
tool 

export (Resource) var texture:Resource
export (Resource) var mesh:Resource

func get_type_string()->String:
	var scope = Profiler.scope(self, "get_type_string", [])

	return "hat"

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	texture = AssetTexture.new()
	mesh = AssetMesh.new()

	connect_subresources()

func connect_subresources()->void :
	var scope = Profiler.scope(self, "connect_subresources", [])

	if not texture.is_connected("changed", self, "on_changed"):
		texture.connect("changed", self, "on_changed")

	if not mesh.is_connected("changed", self, "on_changed"):
		mesh.connect("changed", self, "on_changed")

func disconnect_subresources()->void :
	var scope = Profiler.scope(self, "disconnect_subresources", [])

	texture.disconnect("changed", self, "on_changed")
	mesh.disconnect("changed", self, "on_changed")

func clear_asset()->void :
	var scope = Profiler.scope(self, "clear_asset", [])

	texture.asset_id = 0
	mesh.asset_id = 0
	property_list_changed_notify()

func update_poly(poly:Dictionary)->void :
	var scope = Profiler.scope(self, "update_poly", [poly])

	texture.asset_id = poly.texture.lstrip("asset://").to_int()
	mesh.asset_id = poly.mesh.to_int()
