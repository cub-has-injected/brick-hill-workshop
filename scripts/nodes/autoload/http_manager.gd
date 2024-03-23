extends Node
tool 

const PRINT_DEBUG: = true
const POLL_DURATION: = 1.0 / 60.0
const CHUNK_SIZE: = 40960

class Request:
	enum Type{
		GET, 
		POST
	}

	signal complete(result, metadata)

	var host:String
	var endpoint:String
	var type:int
	var headers: = []
	var post_params: = {}
	var success_callback:FuncRef
	var failure_callback:FuncRef
	var update_callback:FuncRef
	var metadata:Dictionary
	var handle_redirect:bool

	func _init(
		in_host:String, 
		in_endpoint:String, 
		in_type:int, 
		in_headers:Array, 
		in_post_params:Dictionary, 
		in_success_callback:FuncRef, 
		in_failure_callback:FuncRef, 
		in_update_callback:FuncRef, 
		in_metadata:Dictionary, 
		in_handle_redirect:bool
	):
		host = in_host
		endpoint = in_endpoint
		type = in_type
		headers = in_headers
		post_params = in_post_params
		success_callback = in_success_callback
		failure_callback = in_failure_callback
		update_callback = in_update_callback
		metadata = in_metadata
		handle_redirect = in_handle_redirect

	func succeed(response_body:PoolByteArray)->void :
		var scope = Profiler.scope(self, "succeed", [response_body])

		success_callback.call_func(response_body, metadata)
		emit_signal("complete", response_body, metadata)

	func fail(error:String)->void :
		var scope = Profiler.scope(self, "fail", [error])

		failure_callback.call_func(error)
		emit_signal("complete", error, metadata)

	func update(bytes:int, total:int)->void :
		var scope = Profiler.scope(self, "update", [bytes, total])

		if update_callback != null:
			update_callback.call_func(bytes, total)

	static func new_get(in_host:String, in_endpoint:String, headers:Array, in_success_callback:FuncRef, in_failure_callback:FuncRef, in_update_callback:FuncRef, in_metadata:Dictionary, in_handle_redirect:bool = true)->Request:
		return Request.new(in_host, in_endpoint, Type.GET, headers, {}, in_success_callback, in_failure_callback, in_update_callback, in_metadata, in_handle_redirect)

	static func new_post(in_host:String, in_endpoint:String, headers:Array, in_post_params:Dictionary, in_success_callback:FuncRef, in_failure_callback:FuncRef, in_update_callback:FuncRef, in_metadata:Dictionary, in_handle_redirect:bool = true)->Request:
		return Request.new(in_host, in_endpoint, Type.POST, headers, in_post_params, in_success_callback, in_failure_callback, in_update_callback, in_metadata, in_handle_redirect)

const REQUEST_HEADERS: = [
	"User-Agent: Pirulo/1.0 (Godot)", 
	"Accept: */*"
]

signal connect_to_host_finished(result)
signal disconnect_from_host_finished(result)

var _http_clients: = {}
var _http_requests: = {}
var _flushing_queue: = {}

func is_connected_to_host(host:String)->bool:
	var scope = Profiler.scope(self, "is_connected_to_host", [host])

	if host in _http_clients:
		_http_clients[host].poll()
		var status = _http_clients[host].get_status()
		match status:
			HTTPClient.STATUS_DISCONNECTED:
				return false
			HTTPClient.STATUS_RESOLVING:
				return true
			HTTPClient.STATUS_CANT_RESOLVE:
				return false
			HTTPClient.STATUS_CONNECTING:
				return true
			HTTPClient.STATUS_CANT_CONNECT:
				return false
			HTTPClient.STATUS_CONNECTED:
				return true
			HTTPClient.STATUS_REQUESTING:
				return true
			HTTPClient.STATUS_BODY:
				return true
			HTTPClient.STATUS_CONNECTION_ERROR:
				return false
			HTTPClient.STATUS_SSL_HANDSHAKE_ERROR:
				return true

	return false

func connect_to_host(host:String)->void :
	var scope = Profiler.scope(self, "connect_to_host", [host])

	yield (get_tree().create_timer(POLL_DURATION), "timeout")
	if not Engine.get_main_loop():
		return 

	assert ( not host.empty())
	assert ( not is_connected_to_host(host))

	if PRINT_DEBUG:
		print_debug("Connecting to %s" % [host])

	var http = HTTPClient.new()
	http.read_chunk_size = CHUNK_SIZE
	var connect_err = http.connect_to_host(host, - 1, true)
	if connect_err:
		printerr("Connection error: %s" % [connect_err])
		emit_signal("connect_to_host_finished", false)
		http.close()
		return 


	while true:
		http.poll()
		var status = http.get_status()
		match status:
			HTTPClient.STATUS_DISCONNECTED:
				if PRINT_DEBUG:
					print_debug("Disconnected...")
			HTTPClient.STATUS_RESOLVING:
				if PRINT_DEBUG:
					print_debug("Resolving...")
			HTTPClient.STATUS_CANT_RESOLVE:
				printerr("Connection error: Unable to resolve hostname %s" % [host])
				emit_signal("connect_to_host_finished", false)
				http.close()
				return 
			HTTPClient.STATUS_CONNECTING:
				if PRINT_DEBUG:
					print_debug("Connecting...")
			HTTPClient.STATUS_CANT_CONNECT:
				printerr("Connection error: Unable to connect to host %s" % [host])
				emit_signal("connect_to_host_finished", false)
				http.close()
				return 
			HTTPClient.STATUS_CONNECTED:
				if PRINT_DEBUG:
					print_debug("Connected.")
				break
			_:
				printerr("Connection error: Unexpected status %s" % [status])
				emit_signal("connect_to_host_finished", false)
				http.close()
				return 

		yield (get_tree().create_timer(POLL_DURATION), "timeout")

	_http_clients[host] = http
	_http_requests[host] = []
	_flushing_queue[host] = false

	if PRINT_DEBUG:
		print_debug("Connection success")
	emit_signal("connect_to_host_finished", true)

func disconnect_from_host(host:String)->void :
	var scope = Profiler.scope(self, "disconnect_from_host", [host])

	assert ( not host.empty())
	assert (is_connected_to_host(host))

	if PRINT_DEBUG:
		print_debug("Disconnecting from %s" % [host])

	_http_clients[host].close()
	_http_clients.erase(host)
	_http_requests.erase(host)
	_flushing_queue.erase(host)

	if PRINT_DEBUG:
		print_debug("Disconnection success")
	emit_signal("disconnect_from_host_finished", true)

func queue_get(host:String, endpoint:String, headers:Array, success_callback:FuncRef, failure_callback:FuncRef, update_callback:FuncRef = null, metadata:Dictionary = {}, handle_redirect:bool = true)->bool:
	var scope = Profiler.scope(self, "queue_get", [host, endpoint, headers, success_callback, failure_callback, update_callback, metadata, handle_redirect])

	if not is_connected_to_host(host):
		connect_to_host(host)
		var result = yield (self, "connect_to_host_finished")
		if not result:
			var err_string: = "Failed to queue GET request: Connection to host %s failed" % [host]
			printerr(err_string)
			failure_callback.call_func(err_string)
			return false

	if PRINT_DEBUG:
		print_debug("Queueing GET request for host %s, endpoint %s with callbacks %s / %s" % [host, endpoint, success_callback, failure_callback])

	var get_request = Request.new_get(host, endpoint, headers, success_callback, failure_callback, update_callback, metadata, handle_redirect)
	_http_requests[host].append(get_request)
	try_flush_queue(host)
	return true

func queue_post(host:String, endpoint:String, headers:Array, post_params:Dictionary, success_callback:FuncRef, failure_callback:FuncRef, update_callback:FuncRef = null, metadata:Dictionary = {}, handle_redirect:bool = true)->bool:
	var scope = Profiler.scope(self, "queue_post", [host, endpoint, headers, post_params, success_callback, failure_callback, update_callback, metadata, handle_redirect])

	if not is_connected_to_host(host):
		connect_to_host(host)
		var result = yield (self, "connect_to_host_finished")
		if not result:
			var err_string: = "Failed to queue POST request: Connection to host %s failed" % [host]
			printerr(err_string)
			failure_callback.call_func(err_string)
			return false

	if PRINT_DEBUG:
		print_debug("Queueing POST request for host %s, endpoint %s with params %s and callbacks %s / %s" % [host, endpoint, post_params, success_callback, failure_callback])

	var post_request = Request.new_post(host, endpoint, headers, post_params, success_callback, failure_callback, update_callback, metadata)
	_http_requests[host].append(post_request)
	try_flush_queue(host)
	return true

func try_flush_queue(host:String)->void :
	var scope = Profiler.scope(self, "try_flush_queue", [host])

	if not host in _http_clients:
		printerr("Failed to try flushing queue: No connection for host %s" % [host])
		return 

	if not _flushing_queue[host]:
		flush_queue(host)

func flush_queue(host:String)->void :
	var scope = Profiler.scope(self, "flush_queue", [host])

	if not host in _http_clients:
		printerr("Failed to flush queue: No connection for host %s" % [host])
		return 

	if PRINT_DEBUG:
		print_debug("Flushing queue for host %s" % [host])

	_flushing_queue[host] = true

	var requests = _http_requests[host]
	while requests.size() > 0:
		var request = requests.pop_front()
		match request.type:
			Request.Type.GET:
				_send_get(request)
			Request.Type.POST:
				_send_post(request)
		yield (request, "complete")

	_flushing_queue[host] = false

	if PRINT_DEBUG:
		print_debug("Finished flushing queue for host %s" % [host])

func _send_get(request:Request)->void :
	var scope = Profiler.scope(self, "_send_get", [request])

	yield (get_tree().create_timer(POLL_DURATION), "timeout")

	if not request.host in _http_clients:
		printerr("GET request Failed: No connection for host %s" % [request.host])
		return 

	var http = _http_clients[request.host]
	if PRINT_DEBUG:
		print_debug("Sending GET request to %s / %s with headers %s" % [request.host, request.endpoint, REQUEST_HEADERS])

	var request_err = http.request(HTTPClient.METHOD_GET, request.endpoint, REQUEST_HEADERS + request.headers)
	if request_err:
		var err_string = "Request error: %s" % [request_err]
		printerr(err_string)
		request.fail(err_string)
		return 

	while true:
		yield (get_tree().create_timer(POLL_DURATION), "timeout")
		http.poll()
		var status = http.get_status()
		match status:
			HTTPClient.STATUS_REQUESTING:
				pass
			HTTPClient.STATUS_BODY:
				break
			_:
				var err_string = "Unexpected request status %s" % [status]
				printerr(err_string)
				request.fail(err_string)
				return 

	fetch_response(request)

func _send_post(request:Request)->void :
	var scope = Profiler.scope(self, "_send_post", [request])

	yield (get_tree().create_timer(POLL_DURATION), "timeout")

	if not request.host in _http_clients:
		printerr("POST request Failed: No connection for host %s" % [request.host])
		return 

	var http = _http_clients[request.host]
	var query_string = http.query_string_from_dict(request.post_params)

	var request_headers = REQUEST_HEADERS.duplicate()
	request_headers += request.headers
	request_headers.append("Content-Type: application/x-www-form-urlencoded")
	request_headers.append("Content-Length: " + str(query_string.length()))

	if PRINT_DEBUG:
		print_debug("Sending POST request to %s / %s with headers %s and query string %s" % [request.host, request.endpoint, REQUEST_HEADERS, query_string])
	var request_err = http.request(HTTPClient.METHOD_POST, request.endpoint, request_headers, query_string)
	if request_err:
		var err_string = "Request error: %s" % [request_err]
		printerr(err_string)
		request.fail(err_string)
		return 

	while true:
		yield (get_tree().create_timer(POLL_DURATION), "timeout")
		http.poll()
		var status = http.get_status()
		match status:
			HTTPClient.STATUS_REQUESTING:
				pass
			HTTPClient.STATUS_BODY:
				break
			_:
				var err_string = "Unexpected request status %s" % [status]
				printerr(err_string)
				request.fail(err_string)
				return 

	fetch_response(request)

func fetch_response(request:Request)->void :
	var scope = Profiler.scope(self, "fetch_response", [request])

	if PRINT_DEBUG:
		print_debug("Fetching response for host %s" % [request.host])

	if not request.host in _http_clients:
		var err_string = "Fetch response failed: No connection for host %s" % [request.host]
		printerr(err_string)
		request.fail(err_string)
		return 

	var http = _http_clients[request.host]

	var status = http.get_status()
	if status != HTTPClient.STATUS_BODY:
		var err_string = "Fetch response failed: Unexpected status %s" % [status]
		printerr(err_string)
		request.fail(err_string)
		return 

	if not http.has_response():
		var err_string = "Fetch response failed: No response present"
		printerr(err_string)
		request.fail(err_string)
		return 

	var response_headers = http.get_response_headers_as_dictionary()

	var response_bytes: = []

	while http.get_status() == HTTPClient.STATUS_BODY:
		var body_length = http.get_response_body_length()
		var chunk = http.read_response_body_chunk()
		for byte in chunk:
			response_bytes.append(byte)
		request.update(response_bytes.size(), body_length)
		yield (get_tree().create_timer(POLL_DURATION), "timeout")

	handle_response(request, response_headers, response_bytes)

func handle_response(request:Request, headers:Dictionary, response_bytes:Array)->void :
	var scope = Profiler.scope(self, "handle_response", [request, headers, response_bytes])

	if not request.host in _http_clients:
		var err_string = "Handle response failed: No connection for host %s" % [request.host]
		printerr(err_string)
		request.fail(err_string)
		return 

	var http = _http_clients[request.host]

	var response_code = http.get_response_code()
	match response_code:
		200:
			if PRINT_DEBUG:
				print_debug("HTTP OK")
			request.succeed(response_bytes)
		302:
			var location:String
			if "Location" in headers:
				location = headers["Location"]
			elif "location" in headers:
				location = headers["location"]
			else :
				assert (false)

			if PRINT_DEBUG:
				print_debug("HTTP Redirect to %s" % [location])

			if not request.handle_redirect:
				request.succeed(location.to_ascii())
				return 

			var location_comps = location.split("/")
			var location_protocol = location_comps[0]
			var location_host = location_comps[2]
			location_comps.remove(0)
			location_comps.remove(0)
			location_comps.remove(0)
			var location_endpoint = "/%s" % [location_comps.join("/")]

			var new_host = "%s//%s" % [location_protocol, location_host]

			if not is_connected_to_host(new_host):
				connect_to_host(new_host)
				var result = yield (self, "connect_to_host_finished")
				if not result:
					var err_string = "Failed to connect to redirect host %s" % [new_host]
					printerr(err_string)
					request.fail(err_string)
					return 

			yield (get_tree().create_timer(POLL_DURATION), "timeout")

			request.host = new_host
			request.endpoint = location_endpoint
			request.type = Request.Type.GET
			request.post_params.clear()
			request.headers = REQUEST_HEADERS
			_send_get(request)
		_:
			var err_string = "Unexpected response code: %s\nBody:\n%s" % [response_code, PoolByteArray(response_bytes).get_string_from_ascii()]
			printerr(err_string)
			request.fail(err_string)
