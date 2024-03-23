class_name SiteAPI


enum Endpoint{
	None, 
	Token, 
	Info, 
	RetrieveAvatar, 
	RetrieveAsset, 
}

enum AssetType{
	PNG = 1, 
	OBJ = 2, 
	PNG_OBJ = 3
}

enum ContentType{
	JSON, 
	PNG, 
	OBJ
}


const HOST_API = "api.brick-hill.com"

const API_ENDPOINTS: = {
	Endpoint.Token:"/v1/auth/login/token", 
	Endpoint.Info:"/v1/auth/login/info?token=%s", 
	Endpoint.RetrieveAvatar:"/v1/games/retrieveAvatar?id=%s", 
	Endpoint.RetrieveAsset:"/v1/games/retrieveAsset?id=%s&type=%s"
}

const ASSET_KEYS: = {
	AssetType.PNG:"png", 
	AssetType.OBJ:"obj"
}


static func get_token_endpoint()->String:
	return API_ENDPOINTS[Endpoint.Token]

static func get_info_endpoint(token:String)->String:
	return API_ENDPOINTS[Endpoint.Info] % [token]

static func get_retrieve_avatar_endpoint(id:int)->String:
	return API_ENDPOINTS[Endpoint.RetrieveAvatar] % [id]

static func get_retrieve_asset_endpoint(id:int, type:int)->String:
	return API_ENDPOINTS[Endpoint.RetrieveAsset] % [id, ASSET_KEYS[type]]

static func asset_type_to_content_type(asset_type:int)->int:
	match asset_type:
		AssetType.PNG:
			return ContentType.PNG
		AssetType.OBJ:
			return ContentType.OBJ
	return - 1
