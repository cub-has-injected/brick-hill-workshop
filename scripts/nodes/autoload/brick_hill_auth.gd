extends Node

signal login_success()
signal login_error(error)

var _oauth2:OAuth2
var _access_token:String = ""

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	_oauth2 = OAuth2.new()

const PROTOCOL: = "https"
const DOMAIN: = "www.brick-hill.com"
const CLIENT_ID: = 1
const REDIRECT_URI: = "com.brick-hill.app://auth"
const RESPONSE_TYPE: = "code";
const SCOPE: = "access-workshop"

const ACCESS_TOKEN_FILE: = "user://access_token"

func encryption_key()->PoolByteArray:
	var scope = Profiler.scope(self, "encryption_key", [])

	return "CGLHCts6uG54dvfIB4b27MiK5fXLKgg9".to_ascii()

func get_access_token()->String:
	var scope = Profiler.scope(self, "get_access_token", [])

	return _access_token

func try_login()->void :
	var scope = Profiler.scope(self, "try_login", [])

	assert ( not _oauth2.is_authorizing())

	var file: = File.new()
	if file.file_exists(ACCESS_TOKEN_FILE):
		var config_file = ConfigFile.new()
		
		var err = config_file.load_encrypted(ACCESS_TOKEN_FILE, encryption_key())
		assert (err == 0)
		var access_token = config_file.get_value("login", "access_token")
		

		var now = OS.get_unix_time()
		var expires = config_file.get_value("login", "expires")
		if expires > now:
			print("Access token valid, fetching user info...")
			_access_token = access_token
			emit_signal("login_success")
			return 
		else :
			print("Access token expired. Trying OAuth login...")

	_oauth2.connect("authorize_success", self, "authorize_success", [], CONNECT_ONESHOT)
	_oauth2.connect("authorize_timeout", self, "authorize_timeout", [], CONNECT_ONESHOT)
	_oauth2.authorize(PROTOCOL, DOMAIN, CLIENT_ID, REDIRECT_URI, RESPONSE_TYPE, SCOPE)

func clear_access_token()->void :
	var scope = Profiler.scope(self, "clear_access_token", [])

	_access_token = ""

	var dir: = Directory.new()
	if dir.file_exists(ACCESS_TOKEN_FILE):
		dir.remove(ACCESS_TOKEN_FILE)

func authorize_success(code_verifier:String, code:String)->void :
	var scope = Profiler.scope(self, "authorize_success", [code_verifier, code])

	print("Authorize success. Code verifier: %s, Code: %s" % [code_verifier, code])
	var request_uri = _oauth2.get_token_request_uri(PROTOCOL, DOMAIN)
	print("Request URI: %s" % [request_uri])
	var request_headers = _oauth2.get_token_request_headers()
	print("Request Headers: %s" % [request_headers])
	var request_body = _oauth2.get_token_request_body(CLIENT_ID, REDIRECT_URI, code_verifier, code)
	print("Request Body: %s" % [request_body])

	print("Queueing POST")


func authorize_timeout()->void :
	var scope = Profiler.scope(self, "authorize_timeout", [])

	emit_signal("login_error", "Authorization failed: Request timed out")

func token_success(response_body:PoolByteArray, metadata:Dictionary)->void :
	var scope = Profiler.scope(self, "token_success", [response_body, metadata])

	
	var parse_result = JSON.parse(response_body.get_string_from_utf8())
	if parse_result.error:
		emit_signal("login_error", "Login error: Failed to parse response JSON")
		return 

	var json = parse_result.result

	if not "token_type" in json or not "access_token" in json or not "refresh_token" in json or not "expires_in" in json:
		emit_signal("login_error", "Login error: Malformed access token")
		return 

	if json.token_type != "Bearer":
		emit_signal("login_error", "Login error: Unexpected access token type")
		return 

	var now = OS.get_unix_time()
	var expires = now + json.expires_in

	
	var file = ConfigFile.new()
	file.set_value("login", "access_token", json.access_token)
	
	file.set_value("login", "expires", expires)
	file.save_encrypted(ACCESS_TOKEN_FILE, encryption_key())

	_access_token = json.access_token
	emit_signal("login_success")

func token_error(error:String, metadata:Dictionary)->void :
	var scope = Profiler.scope(self, "token_error", [error, metadata])

	printerr("Login error: %s" % [error])
	emit_signal("login_error", error)
