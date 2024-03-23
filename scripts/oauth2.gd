class_name OAuth2

signal authorize_success(code_verifier, code)
signal authorize_timeout()

const CODE_CHALLENGE_METHOD: = "S256"

var _authorizing: = false
var _tcp_server:TCP_Server
var _auth_state:String
var _code_verifier:String

func is_authorizing()->bool:
	var scope = Profiler.scope(self, "is_authorizing", [])

	return _authorizing

func get_token_request_uri(protocol:String, domain:String)->String:
	var scope = Profiler.scope(self, "get_token_request_uri", [protocol, domain])

	return "%s://%s%s" % [protocol, domain, get_token_request_endpoint()]

func get_token_request_endpoint()->String:
	var scope = Profiler.scope(self, "get_token_request_endpoint", [])

	return "/oauth/token"

func get_token_request_headers()->Array:
	var scope = Profiler.scope(self, "get_token_request_headers", [])

	return ["Content-Type: application/x-www-form-urlencoded"]

func get_token_request_body(client_id:int, redirect_uri:String, code_verifier:String, code:String)->String:
	var scope = Profiler.scope(self, "get_token_request_body", [client_id, redirect_uri, code_verifier, code])

	var params = get_token_request_params(client_id, redirect_uri, code_verifier, code)
	var request_body = ""
	for param in params:
		request_body += "%s=%s" % [param, String(params[param]).http_escape()]
		if param != params.keys()[ - 1]:
			request_body += "&"
	return request_body

func get_token_request_params(client_id:int, redirect_uri:String, code_verifier:String, code:String)->Dictionary:
	var scope = Profiler.scope(self, "get_token_request_params", [client_id, redirect_uri, code_verifier, code])

	return {
		"grant_type":"authorization_code", 
		"client_id":client_id, 
		"redirect_uri":redirect_uri, 
		"code_verifier":code_verifier, 
		"code":code, 
	}

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	print("OAuth2 Init")
	_tcp_server = TCP_Server.new()

func authorize(protocol:String, domain:String, client_id:int, redirect_uri:String, response_type:String, scope:String)->void :
	var prof_scope = Profiler.scope(self, "authorize", [protocol, domain, client_id, redirect_uri, response_type, scope])

	print("OAuth2 Authorize")

	assert ( not _authorizing)
	_authorizing = true

	
	_code_verifier = random_string(128)
	assert (_code_verifier.length() <= 128)
	var sha256: = _code_verifier.sha256_buffer()
	var base64: = Marshalls.raw_to_base64(sha256)

	var code_challenge = base64.replace("+", "-").replace("/", "_").replace("=", "")

	
	_auth_state = random_string(40)

	var target_uri: = "%s://%s/oauth/authorize?client_id=%s&redirect_uri=%s&response_type=%s&scope=%s&state=%s&code_challenge=%s&code_challenge_method=%s" % [
		protocol, 
		domain, 
		client_id, 
		redirect_uri, 
		response_type, 
		scope, 
		_auth_state, 
		code_challenge, 
		CODE_CHALLENGE_METHOD
	]

	match OS.get_name():
		"OSX":
			authorize_macos(target_uri)
		_:
			authorize_default(target_uri)


func authorize_default(target_uri:String):
	var scope = Profiler.scope(self, "authorize_default", [target_uri])

	print("OAuth2 Authorize Default")

	
	_tcp_server.listen(34254, "127.0.0.1")

	
	OS.shell_open(target_uri)

	
	var code: = ""
	var timeout: = 30.0
	while timeout > 0.0:
		yield (Engine.get_main_loop().create_timer(0.5), "timeout")
		timeout -= 0.5

		if _tcp_server.is_connection_available():
			
			var connection: = _tcp_server.take_connection()

			var key = connection.get_utf8_string(5)
			assert (key == "state")

			var state_length = connection.get_u64()

			var state = connection.get_utf8_string(state_length)
			assert (state.length() > 0 and state == _auth_state)

			key = connection.get_utf8_string(4)
			assert (key == "code")

			var code_length = connection.get_u64()
			code = connection.get_utf8_string(code_length)
			break

	
	_tcp_server.stop()

	_authorizing = false

	if code.empty():
		emit_signal("authorize_timeout")
	else :
		emit_signal("authorize_success", _code_verifier, code)

var macos_auth_timer = null
func authorize_macos(target_uri:String):
	var scope = Profiler.scope(self, "authorize_macos", [target_uri])

	print("OAuth2 Authorize macOS")
	
#	SetupManager.brick_hill_native.macos.register_url_handler(funcref(self, "authorize_macos_success"))

	
	OS.shell_open(target_uri)

	macos_auth_timer = Engine.get_main_loop().create_timer(30.0)
	macos_auth_timer.connect("timeout", self, "authorize_macos_timeout")

func authorize_macos_timeout():
	var scope = Profiler.scope(self, "authorize_macos_timeout", [])

	print("OAuth2 Authorize macOS Timeout")
#	SetupManager.brick_hill_native.macos.call_deferred("unregister_url_handler")
	_authorizing = false
	emit_signal("authorize_timeout")

func authorize_macos_success(code:String):
	var scope = Profiler.scope(self, "authorize_macos_success", [code])

	print("OAuth2 macOS Success")
	macos_auth_timer.disconnect("timeout", self, "authorize_macos_timeout")
	print("OAuth2 unregistering URL handler")
#	SetupManager.brick_hill_native.macos.call_deferred("unregister_url_handler")
	_authorizing = false
	print("OAuth2 emitting success signal")
	emit_signal("authorize_success", _code_verifier, code)
	print("OAuth2 success routine finished")


func random_string(length:int)->String:
	var scope = Profiler.scope(self, "random_string", [length])

	var state: = PoolByteArray()
	for i in range(0, length):
		match randi() % 4:
			0:
				
				state.append(97 + randi() % (122 - 97))
			1:
				
				state.append(65 + randi() % (90 - 65))
			2:
				
				state.append(48 + randi() % (57 - 48))
			3:
				
				match randi() % 4:
					0:
						state.append(45)
					1:
						state.append(46)
					2:
						state.append(95)
					3:
						state.append(126)
	return state.get_string_from_ascii()
