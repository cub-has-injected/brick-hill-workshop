class_name AvatarData
extends Resource
tool 

export (int) var avatar_id: = 0 setget set_avatar_id

export (Resource) var asset_face:Resource
export (Array) var assets_hats: = []
export (Resource) var asset_head:Resource
export (Resource) var asset_tool:Resource
export (Resource) var asset_pants:Resource
export (Resource) var asset_shirt:Resource
export (Resource) var asset_figure:Resource
export (Resource) var asset_t_shirt:Resource

export (Color) var color_head: = Color("#f3b700")
export (Color) var color_torso: = Color("#3292d3")
export (Color) var color_left_arm: = Color("#f3b700")
export (Color) var color_left_leg: = Color("#1c4399")
export (Color) var color_right_arm: = Color("#f3b700")
export (Color) var color_right_leg: = Color("#1c4399")

func set_avatar_id(new_avatar_id:int)->void :
	if avatar_id != new_avatar_id:
		avatar_id = new_avatar_id
		if Engine.get_main_loop():
			update_avatar_data()

func _init()->void :
	if resource_name.empty():
		resource_name = "Avatar Data"

	asset_face = AssetPolyFace.new()

	asset_pants = AssetPolyPants.new()

	asset_shirt = AssetPolyShirt.new()

	asset_t_shirt = AssetPolyTShirt.new()

	asset_head = AssetPolyHead.new()

	asset_tool = AssetPolyTool.new()

	asset_figure = AssetPolyFigure.new()

	assets_hats = [
		AssetPolyHat.new(), 
		AssetPolyHat.new(), 
		AssetPolyHat.new(), 
		AssetPolyHat.new(), 
		AssetPolyHat.new(), 
	]

	connect_subresources()

	clear_avatar_data()

func connect_subresources()->void :
	asset_face.connect_subresources()
	asset_pants.connect_subresources()
	asset_shirt.connect_subresources()
	asset_t_shirt.connect_subresources()
	asset_head.connect_subresources()
	asset_tool.connect_subresources()
	asset_figure.connect_subresources()

	assets_hats[0].connect_subresources()
	assets_hats[1].connect_subresources()
	assets_hats[2].connect_subresources()
	assets_hats[3].connect_subresources()
	assets_hats[4].connect_subresources()

	asset_face.connect("changed", self, "on_asset_changed")
	asset_pants.connect("changed", self, "on_asset_changed")
	asset_shirt.connect("changed", self, "on_asset_changed")
	asset_t_shirt.connect("changed", self, "on_asset_changed")
	asset_head.connect("changed", self, "on_asset_changed")
	asset_tool.connect("changed", self, "on_asset_changed")
	asset_figure.connect("changed", self, "on_asset_changed")

	assets_hats[0].connect("changed", self, "on_asset_changed")
	assets_hats[1].connect("changed", self, "on_asset_changed")
	assets_hats[2].connect("changed", self, "on_asset_changed")
	assets_hats[3].connect("changed", self, "on_asset_changed")
	assets_hats[4].connect("changed", self, "on_asset_changed")

func disconnect_subresources()->void :
	asset_face.disconnect_subresources()
	asset_pants.disconnect_subresources()
	asset_shirt.disconnect_subresources()
	asset_t_shirt.disconnect_subresources()
	asset_head.disconnect_subresources()
	asset_tool.disconnect_subresources()
	asset_figure.disconnect_subresources()

	assets_hats[0].disconnect_subresources()
	assets_hats[1].disconnect_subresources()
	assets_hats[2].disconnect_subresources()
	assets_hats[3].disconnect_subresources()
	assets_hats[4].disconnect_subresources()

	asset_face.disconnect("changed", self, "on_asset_changed")
	asset_pants.disconnect("changed", self, "on_asset_changed")
	asset_shirt.disconnect("changed", self, "on_asset_changed")
	asset_t_shirt.disconnect("changed", self, "on_asset_changed")
	asset_head.disconnect("changed", self, "on_asset_changed")
	asset_tool.disconnect("changed", self, "on_asset_changed")
	asset_figure.disconnect("changed", self, "on_asset_changed")

	assets_hats[0].disconnect("changed", self, "on_asset_changed")
	assets_hats[1].disconnect("changed", self, "on_asset_changed")
	assets_hats[2].disconnect("changed", self, "on_asset_changed")
	assets_hats[3].disconnect("changed", self, "on_asset_changed")
	assets_hats[4].disconnect("changed", self, "on_asset_changed")

func on_asset_changed()->void :
	emit_signal("changed")

func clear_avatar_data()->void :
	asset_face.asset_id = 0
	asset_pants.asset_id = 0
	asset_shirt.asset_id = 0
	asset_t_shirt.asset_id = 0
	asset_head.asset_id = 0
	asset_tool.asset_id = 0
	asset_figure.asset_id = 0

	for asset_hat in assets_hats:
		asset_hat.asset_id = 0

	color_head = Color("#f3b700")
	color_torso = Color("#3292d3")
	color_left_arm = Color("#f3b700")
	color_left_leg = Color("#1c4399")
	color_right_arm = Color("#f3b700")
	color_right_leg = Color("#1c4399")

	emit_signal("changed")

func update_avatar_data()->void :
	clear_avatar_data()

	if avatar_id == 0:
		return 


func request_success_callback(response_body:PoolByteArray, _metadata:Dictionary)->void :
	var response_string = response_body.get_string_from_ascii()
	print_debug("Response string: %s" % [response_string])

	var parse_result = JSON.parse(response_string)
	

	if parse_result.error:
		printerr("Error %s parsing JSON at line %s: %s" % [parse_result.error, parse_result.error_string, parse_result.error_line])
		return 

	var request_result = parse_result.result

	update_colors(request_result)

	yield (Engine.get_main_loop(), "idle_frame")

	asset_face.asset_id = request_result.items.face

	yield (Engine.get_main_loop(), "idle_frame")

	asset_pants.asset_id = request_result.items.pants

	yield (Engine.get_main_loop(), "idle_frame")

	asset_shirt.asset_id = request_result.items.shirt

	yield (Engine.get_main_loop(), "idle_frame")

	asset_t_shirt.asset_id = request_result.items.tshirt

	yield (Engine.get_main_loop(), "idle_frame")

	asset_head.asset_id = request_result.items.head

	yield (Engine.get_main_loop(), "idle_frame")

	asset_tool.asset_id = request_result.items["tool"]

	yield (Engine.get_main_loop(), "idle_frame")

	asset_figure.asset_id = request_result.items.figure

	yield (Engine.get_main_loop(), "idle_frame")

	update_hat_assets(request_result)

	emit_signal("changed")

func request_failed_callback(error:String)->void :
	printerr("Failed to update avatar data: %s" % [error])
	clear_avatar_data()

func update_colors(request_result:Dictionary)->void :
	color_head = request_result.colors.head
	color_torso = request_result.colors.torso
	color_left_arm = request_result.colors.left_arm
	color_left_leg = request_result.colors.left_leg
	color_right_arm = request_result.colors.right_arm
	color_right_leg = request_result.colors.right_leg

func update_hat_assets(request_result:Dictionary)->void :
	for i in range(0, request_result.items.hats.size()):
		assets_hats[i].asset_id = request_result.items.hats[i]
		yield (Engine.get_main_loop(), "idle_frame")
