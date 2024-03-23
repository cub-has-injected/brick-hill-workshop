


extends Node

const ASSET_HOST: = "https://api.brick-hill.com"
const ASSET_ENDPOINT: = "/v1/assets/get/"
const CHUNK_SIZE: = 40960
const POLL_INTERVAL: = 1.0 / 60.0

signal asset_loaded(asset_id)
signal download_complete(asset_id)

var _dir:Directory
var _http:HTTPClient

var _downloading_asset: = ""
var _loading_assets: = {}
var _loaded_assets: = {}

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	_dir = Directory.new()
	var result = _dir.make_dir_recursive("user://assets/")
	assert (result == OK, "Unexpected make dir error: %s" % [result])

	_http = HTTPClient.new()
	_http.read_chunk_size = CHUNK_SIZE

func connect_to_host(host:String):
	var scope = Profiler.scope(self, "connect_to_host", [host])

	
	
	yield (get_tree().create_timer(POLL_INTERVAL), "timeout")

	var result = _http.connect_to_host(host, - 1, true)
	if result != OK:
		handle_error("Failed to connect to host. Error: %s" % [result])
		return ERR_QUERY_FAILED

	yield (poll_until(HTTPClient.STATUS_RESOLVING), "completed")
	print("Resolving...")

	yield (poll_until(HTTPClient.STATUS_CONNECTING), "completed")
	print("Connecting...")

	yield (poll_until(HTTPClient.STATUS_CONNECTED), "completed")
	print("Connected...")

	return OK

func get_request(url:String):
	var scope = Profiler.scope(self, "get_request", [url])

	
	
	yield (get_tree().create_timer(POLL_INTERVAL), "timeout")

	var result

	url = url.lstrip("http://")
	url = url.lstrip("https://")

	var parts = url.split("/", false)

	var host = parts[0]
	parts.remove(0)
	var target = "/" + parts.join("/")

	print("Host: %s, Target: %s" % [host, target])

	result = yield (connect_to_host(host), "completed")
	if result != OK:
		handle_error("Unexpected connection error: %s" % [result])
		return ERR_QUERY_FAILED

	result = _http.request(HTTPClient.METHOD_GET, target, PoolStringArray())
	if result != OK:
		handle_error("Failed to send request. Error: %s" % [result])
		return ERR_QUERY_FAILED

	result = yield (poll_until(HTTPClient.STATUS_REQUESTING), "completed")
	if result != OK:
		handle_error("Failed to send request. Error: %s" % [result])
		return ERR_QUERY_FAILED

	print("Requesting %s..." % target)

	result = yield (poll_until(HTTPClient.STATUS_BODY), "completed")
	if result != OK:
		handle_error("Failed to send request. Error: %s" % [result])
		return ERR_QUERY_FAILED

	print("Receiving response code...")
	var response_code = _http.get_response_code()

	print("Receiving header...")
	var header = _http.get_response_headers_as_dictionary()

	match response_code:
		HTTPClient.RESPONSE_FOUND:
			var location
			if "location" in header:
				location = header.location
			elif "Location" in header:
				location = header.Location
			else :
				assert ("Invalid redirect location")

			print("Redirect to %s" % [location])
			result = yield (get_request(location), "completed")
			if not result is Array:
				handle_error("Unexpected redirect error: %s" % [result])
				return ERR_QUERY_FAILED
			return result
		HTTPClient.RESPONSE_OK:
			result = yield (read_until(HTTPClient.STATUS_CONNECTED), "completed")
			if not result is PoolByteArray:
				handle_error("Unexpected read error: %s" % [result])
				return ERR_QUERY_FAILED
			return [response_code, header, result]
		_:
			handle_error("Unexpected response code: %s" % [response_code])
			return ERR_QUERY_FAILED

	handle_error("get_request fell through to return statement")
	return ERR_BUG

func get_asset_load_progress(asset_id:String)->float:
	var scope = Profiler.scope(self, "get_asset_load_progress", [asset_id])

	if asset_id in _loaded_assets:
		return 1.0
	elif asset_id in _loading_assets:
		return _loading_assets[asset_id]
	else :
		return 0.0

func get_asset(asset_id:String)->Resource:
	var scope = Profiler.scope(self, "get_asset", [asset_id])

	
	
	yield (get_tree().create_timer(POLL_INTERVAL), "timeout")

	
	if asset_id in _loaded_assets:
		
		return _loaded_assets[asset_id]

	
	if asset_id in _loading_assets:
		print("Asset %s is currently loading. Yielding..." % [asset_id])
		while asset_id in _loading_assets:
			yield (self, "asset_loaded")
		return _loaded_assets[asset_id]

	
	if ResourceLoader.exists("user://assets/%s.res" % [asset_id]):
		_loading_assets[asset_id] = 0.0

		var loader = ResourceLoader.load_interactive("user://assets/%s.res" % [asset_id])
		var load_stage = loader.get_stage()
		var load_stages = loader.get_stage_count()
		while load_stage < load_stages:
			loader.poll()
			load_stage = loader.get_stage()
			_loading_assets[asset_id] = float(load_stage) / float(load_stages)
			yield (get_tree().create_timer(POLL_INTERVAL), "timeout")
		var asset = loader.get_resource()
		if asset:
			_loading_assets.erase(asset_id)
			_loaded_assets[asset_id] = asset
			print("Loaded asset %s from disk" % [asset_id])
			emit_signal("asset_loaded", asset_id)
			return asset

	
	_loading_assets[asset_id] = 0.0
	var response = yield (download(asset_id), "completed")
	if not response is Array:
		printerr("Unexpected download error: %s" % [response])
		return ERR_QUERY_FAILED

	var response_code = response[0]
	var header = response[1]
	var bytes = response[2]

	print("Response code: %s\nHeader:\n%s\nBytes:\n%s" % [response_code, header, bytes])
	var content_type = header["Content-Type"]

	var asset = create_resource(content_type, bytes)

	ResourceSaver.save("user://assets/%s.res" % asset_id, asset)

	_loading_assets.erase(asset_id)
	_loaded_assets[asset_id] = asset
	print("Downloaded asset %s from site" % [asset_id])
	emit_signal("asset_loaded", asset_id)
	return asset

var resource_constructors: = {
	"image/png":funcref(NativePanoramaPNG, "native_panorama_png"), 
}

func create_resource(content_type:String, bytes:PoolByteArray)->Resource:
	var scope = Profiler.scope(self, "create_resource", [content_type, bytes])

	var asset:Resource = null

	if content_type in resource_constructors:
		asset = resource_constructors[content_type].call_func(bytes)

	return asset

func create_resource_png(bytes:PoolByteArray)->ImageTexture:
	var scope = Profiler.scope(self, "create_resource_png", [bytes])

	var image = Image.new()
	var result = image.load_png_from_buffer(bytes)
	assert (result == OK, "Load PNG Error: %s" % [result])
	var asset = ImageTexture.new()
	asset.create_from_image(image)
	return asset

func create_resource_jpg(bytes:PoolByteArray)->ImageTexture:
	var scope = Profiler.scope(self, "create_resource_jpg", [bytes])

	var image = Image.new()
	var result = image.load_jpg_from_buffer(bytes)
	assert (result == OK, "Load JPG Error: %s" % [result])
	var asset = ImageTexture.new()
	asset.create_from_image(image)
	return asset

func create_resource_tga(bytes:PoolByteArray)->ImageTexture:
	var scope = Profiler.scope(self, "create_resource_tga", [bytes])

	var image = Image.new()
	var result = image.load_tga_from_buffer(bytes)
	assert (result == OK, "Load TGA Error: %s" % [result])
	var asset = ImageTexture.new()
	asset.create_from_image(image)
	return asset

func create_resource_webp(bytes:PoolByteArray)->ImageTexture:
	var scope = Profiler.scope(self, "create_resource_webp", [bytes])

	var image = Image.new()
	var result = image.load_webp_from_buffer(bytes)
	assert (result == OK, "Load WEBP Error: %s" % [result])
	var asset = ImageTexture.new()
	asset.create_from_image(image)
	return asset

var _download_lock: = false
func download(asset_id:String):
	var scope = Profiler.scope(self, "download", [asset_id])

	
	
	yield (get_tree().create_timer(POLL_INTERVAL), "timeout")

	while _download_lock:
		print("Download in progress, yielding...")
		yield (self, "download_complete")

	_download_lock = true
	_downloading_asset = asset_id

	var result = yield (get_request("%s%s%s" % [ASSET_HOST, ASSET_ENDPOINT, asset_id]), "completed")
	if not result is Array:
		handle_error("Unexpected get request error: %s" % [result])
		return ERR_QUERY_FAILED

	_http.close()
	_downloading_asset = ""
	_download_lock = false

	emit_signal("download_complete", asset_id)

	return result

func handle_error(message:String)->void :
	var scope = Profiler.scope(self, "handle_error", [message])

	printerr(message)
	_http.close()

func poll_until(status:int)->int:
	var scope = Profiler.scope(self, "poll_until", [status])

	
	
	yield (get_tree().create_timer(POLL_INTERVAL), "timeout")

	var start_status = _http.get_status()
	if start_status == status:
		return OK

	while true:
		var result = _http.poll()
		if result != OK:
			handle_error("Failed to poll request. Error: %s" % [result])
			return result

		var new_status = _http.get_status()
		if new_status != start_status:
			if new_status == status:
				return OK
			else :
				handle_error("Unexpected status: %s" % [new_status])
				return ERR_QUERY_FAILED

		yield (get_tree().create_timer(0.5), "timeout")

	
	handle_error("poll_until fell through to return statement")
	return ERR_BUG

func read_until(status:int)->PoolByteArray:
	var scope = Profiler.scope(self, "read_until", [status])

	
	
	yield (get_tree().create_timer(POLL_INTERVAL), "timeout")

	var start_status = _http.get_status()
	if start_status == status:
		return OK

	var bytes = PoolByteArray()

	var body_length = _http.get_response_body_length()
	while true:
		bytes += _http.read_response_body_chunk()

		var new_status = _http.get_status()
		if new_status != start_status:
			if new_status == status:
				return bytes
			else :
				handle_error("Unexpected status: %s" % [new_status])
				return ERR_QUERY_FAILED

		assert (_downloading_asset != "")
		_loading_assets[_downloading_asset] = float(bytes.size()) / float(body_length)
		yield (get_tree().create_timer(POLL_INTERVAL), "timeout")

	
	handle_error("read_until fell through to return statement")
	return ERR_BUG
