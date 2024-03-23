class_name HTTPManagerTest
extends Node
tool 

enum Action{
	None, 
	ConnectMainAPI, 
	DisconnectMainAPI, 
	GetLoginToken, 
	GetUserInfo, 
	GetAvatarData, 
	GetAssetData
}

const ACTIONS: = {
	Action.ConnectMainAPI:"connect_main_api", 
	Action.DisconnectMainAPI:"disconnect_main_api", 
	Action.GetLoginToken:"get_login_token", 
	Action.GetUserInfo:"get_user_info", 
	Action.GetAvatarData:"get_avatar_data", 
	Action.GetAssetData:"get_asset_data", 
}

export (Action) var action setget set_action

func set_action(new_action:int)->void :
	if action != new_action:
		if new_action in ACTIONS:
			call(ACTIONS[new_action])

func connect_main_api()->void :
	print("Connecting Main API")
	HTTPManager.connect_to_host(SiteAPI.HOST_API)

func disconnect_main_api()->void :
	print("Disconnecting Main API")
	HTTPManager.disconnect_from_host(SiteAPI.HOST_API)

func get_login_token()->void :
	HTTPManager.queue_post(
		SiteAPI.HOST_API, 
		SiteAPI.get_token_endpoint(), 
		{
			"username":SiteConstants.USER_DEV, 
			"password":SiteConstants.PASS_DEV
		}, 
		funcref(self, "login_token_callback"), 
		funcref(self, "request_failed_callback")
	)

func get_user_info()->void :
	HTTPManager.queue_get(
		SiteAPI.HOST_API, 
		SiteAPI.get_info_endpoint("0aa499b3-2238-4f2a-bae9-855a33658cc8"), 
		funcref(self, "user_info_callback"), 
		funcref(self, "request_failed_callback")
	)

func get_avatar_data()->void :
	print("Getting avatar data")
	HTTPManager.queue_get(SiteAPI.HOST_API, SiteAPI.get_retrieve_avatar_endpoint(253637), funcref(self, "avatar_data_callback"), funcref(self, "request_failed_callback"))
	HTTPManager.queue_get(SiteAPI.HOST_API, SiteAPI.get_retrieve_avatar_endpoint(253639), funcref(self, "avatar_data_callback"), funcref(self, "request_failed_callback"))
	HTTPManager.queue_get(SiteAPI.HOST_API, SiteAPI.get_retrieve_avatar_endpoint(253640), funcref(self, "avatar_data_callback"), funcref(self, "request_failed_callback"))
	HTTPManager.queue_get(SiteAPI.HOST_API, SiteAPI.get_retrieve_avatar_endpoint(253641), funcref(self, "avatar_data_callback"), funcref(self, "request_failed_callback"))

func get_asset_data()->void :
	print("Getting asset data")
	HTTPManager.queue_get(SiteAPI.HOST_API, SiteAPI.get_retrieve_asset_endpoint(120701, SiteAPI.AssetType.PNG), funcref(self, "asset_png_callback"), funcref(self, "request_failed_callback"))
	HTTPManager.queue_get(SiteAPI.HOST_API, SiteAPI.get_retrieve_asset_endpoint(120701, SiteAPI.AssetType.OBJ), funcref(self, "asset_obj_callback"), funcref(self, "request_failed_callback"))

func login_token_callback(response_body:PoolByteArray)->void :
	print("Login token callback: %s" % [response_body])

	var response_string: = response_body.get_string_from_ascii()
	var parse_result: = JSON.parse(response_string)

	if parse_result.error:
		printerr("Error %s parsing JSON at line %s: %s" % [parse_result.error, parse_result.error_string, parse_result.error_line])
		return 

	print_debug("Response JSON: %s" % [parse_result.result])

func user_info_callback(response_body:PoolByteArray)->void :
	print("User info callback: %s" % [response_body])

	var response_string: = response_body.get_string_from_ascii()
	var parse_result: = JSON.parse(response_string)

	if parse_result.error:
		printerr("Error %s parsing JSON at line %s: %s" % [parse_result.error, parse_result.error_string, parse_result.error_line])
		return 

	print_debug("Response JSON: %s" % [parse_result.result])

func avatar_data_callback(response_body:PoolByteArray)->void :
	print("Avatar data callback: %s" % [response_body])

	var response_string: = response_body.get_string_from_ascii()
	var parse_result: = JSON.parse(response_string)

	if parse_result.error:
		printerr("Error %s parsing JSON at line %s: %s" % [parse_result.error, parse_result.error_string, parse_result.error_line])
		return 

	print_debug("Response JSON: %s" % [parse_result.result])

func asset_png_callback(response_body:PoolByteArray)->void :
	var png_image = Image.new()
	png_image.load_png_from_buffer(response_body)
	if png_image.get_format() != Image.FORMAT_RGBA8:
		png_image.convert(Image.FORMAT_RGBA8)
	print_debug("Response PNG: %s" % [png_image])

func asset_obj_callback(response_body:PoolByteArray)->void :
	print("Asset OBJ callback: %s" % [response_body])
	var obj_string = response_body.get_string_from_ascii()
	print_debug("Response OBJ: %s" % [obj_string])

func request_failed_callback(error:String)->void :
	printerr(error)
