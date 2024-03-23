extends Control
tool 


export (SiteAPI.Endpoint) var request setget set_request
export (String) var api_token
export (int) var avatar_id
export (Resource) var avatar_data:Resource
export (int) var asset_id
export (SiteAPI.AssetType) var asset_type
export (ImageTexture) var png_asset:ImageTexture
export (PoolStringArray) var obj_asset:PoolStringArray


func set_request(new_request:int)->void :
	if request != new_request:
		match new_request:
			SiteAPI.Endpoint.Token:
				var request = SiteAPI.Request.new(
					SiteAPI.get_token_endpoint(), 
					SiteAPI.ContentType.JSON, 
					HTTPClient.METHOD_POST, 
					{
						"username":SiteConstants.USER_DEV, 
						"password":SiteConstants.PASS_DEV
					}
				)

				request.send()
				var response = yield (request, "request_finished")
				var request_state = response[0]
				var request_result = response[1]
				if request_state == SiteAPI.Request.State.Complete and request_result is Dictionary:
					api_token = request_result.success
					property_list_changed_notify()
				else :
					printerr("Request failed. State: %s, Result: %s" % [request_state, request_result])
			SiteAPI.Endpoint.Info:
				var request = SiteAPI.Request.new(SiteAPI.get_info_endpoint(api_token))
				request.send()
				var response = yield (request, "request_finished")
				var request_state = response[0]
				var request_result = response[1]
				if request_state == SiteAPI.Request.State.Complete and request_result is Dictionary:
					avatar_id = request_result.user.id
					property_list_changed_notify()
				else :
					printerr("Request failed. State: %s, Result: %s" % [request_state, request_result])
			SiteAPI.Endpoint.RetrieveAvatar:
				avatar_data.avatar_id = avatar_id
			SiteAPI.Endpoint.RetrieveAsset:
				var content_type:int
				match asset_type:
					SiteAPI.AssetType.PNG:
						content_type = SiteAPI.ContentType.PNG
					SiteAPI.AssetType.OBJ:
						content_type = SiteAPI.ContentType.OBJ

				var request = SiteAPI.Request.new(
					SiteAPI.get_retrieve_asset_endpoint(asset_id, asset_type), 
					content_type
				)
				request.send()
				var response = yield (request, "request_finished")
				var request_state = response[0]
				var request_result = response[1]
				if request_state == SiteAPI.Request.State.Complete:
					match asset_type:
						SiteAPI.AssetType.PNG:
							if request_result is Image:
								png_asset = ImageTexture.new()
								png_asset.create_from_image(request_result)
								property_list_changed_notify()
							else :
								printerr("Request failed: Returned data is not an Image")
								return 
						SiteAPI.AssetType.OBJ:
							if request_result is PoolStringArray:
								obj_asset = request_result
								property_list_changed_notify()
							else :
								printerr("Request failed: Returned data is not a PoolStringArray")
								return 
				else :
					printerr("Request failed. State: %s, Result: %s" % [request_state, request_result])

