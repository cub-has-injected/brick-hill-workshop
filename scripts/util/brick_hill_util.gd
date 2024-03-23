class_name BrickHillUtil

const TEMP_DIR: = "user://.temp"

enum SelectionMode{
	SELECT_NODES = 0, 
	PAINT_NODES = 1, 
	PAINT_FACES = 2, 
	TOGGLE_LOCK = 3, 
	TOGGLE_ANCHOR = 4
}

enum PaintMode{
	NONE = 0, 
	COLOR = 1, 
	SURFACE = 2, 
	MATERIAL = 3
}

enum CollisionType{
	CONVEX = 0, 
	CONCAVE = 1, 
	SPHERE = 2, 
	BOX = 3
}

enum ObjectMode{
	STATIC = 0, 
	DYNAMIC = 1
}

static func recursive_traverse(node:Node, f:FuncRef, params:Array = []):
	f.call_funcv([node] + params)
	for child in node.get_children():
		recursive_traverse(child, f, params)

static func connect_checked(object:Object, signal_name:String, target:Object, method:String, binds:Array = [], flags:int = 0):
	if not object:
		return 

	if not target:
		return 

	if not object.is_connected(signal_name, target, method):
		object.connect(signal_name, target, method, binds, flags)

static func disconnect_checked(object:Object, signal_name:String, target:Object, method:String):
	if not object:
		return 

	if not target:
		return 

	if object.is_connected(signal_name, target, method):
		object.disconnect(signal_name, target, method)

static func enum_hint_string(enumeration:Dictionary)->String:
	var keys = PoolStringArray()
	for key in enumeration:
		keys.append(key.capitalize())
	return PoolStringArray(keys).join(",")

static func get_temp_file_for_path(path:String)->String:
	var path_normalized = path.replace("\\", "/")
	var path_comps = path_normalized.split("/")
	var file_name = path_comps[ - 1]
	var file_name_comps = file_name.split(".")

	return TEMP_DIR + "/" + file_name_comps[0] + ".scn"

static func get_error_string(error:int)->String:
	assert (error != OK)

	match error:
		FAILED:
			return "Failed"
		ERR_UNAVAILABLE:
			return "Unavailable"
		ERR_UNCONFIGURED:
			return "Unconfigured"
		ERR_UNAUTHORIZED:
			return "Unauthorized"
		ERR_PARAMETER_RANGE_ERROR:
			return "Parameter range error."
		ERR_OUT_OF_MEMORY:
			return "Out of memory"
		ERR_FILE_NOT_FOUND:
			return "File not found"
		ERR_FILE_BAD_DRIVE:
			return "Bad drive"
		ERR_FILE_BAD_PATH:
			return "Bad path"
		ERR_FILE_NO_PERMISSION:
			return "No permission"
		ERR_FILE_ALREADY_IN_USE:
			return "File already in use"
		ERR_FILE_CANT_OPEN:
			return "Can't open file"
		ERR_FILE_CANT_WRITE:
			return "Can't write file"
		ERR_FILE_CANT_READ:
			return "Can't read file"
		ERR_FILE_UNRECOGNIZED:
			return "File unrecognized"
		ERR_FILE_CORRUPT:
			return "File corrupt"
		ERR_FILE_MISSING_DEPENDENCIES:
			return "File missing dependencies"
		ERR_FILE_EOF:
			return "End of file"
		ERR_CANT_OPEN:
			return "Can't open"
		ERR_CANT_CREATE:
			return "Can't create"
		ERR_QUERY_FAILED:
			return "Query failed"
		ERR_ALREADY_IN_USE:
			return "Already in use"
		ERR_LOCKED:
			return "Locked"
		ERR_TIMEOUT:
			return "Timeout"
		ERR_CANT_CONNECT:
			return "Can't connect"
		ERR_CANT_RESOLVE:
			return "Can't resolve"
		ERR_CONNECTION_ERROR:
			return "Connection error"
		ERR_CANT_ACQUIRE_RESOURCE:
			return "Can't acquire resource"
		ERR_CANT_FORK:
			return "Can't fork process"
		ERR_INVALID_DATA:
			return "Invalid data"
		ERR_INVALID_PARAMETER:
			return "Invalid parameter"
		ERR_ALREADY_EXISTS:
			return "Already exists"
		ERR_DOES_NOT_EXIST:
			return "Does not exist"
		ERR_DATABASE_CANT_READ:
			return "Database read error"
		ERR_DATABASE_CANT_WRITE:
			return "Database write error"
		ERR_COMPILATION_FAILED:
			return "Compilation failed"
		ERR_METHOD_NOT_FOUND:
			return "Method not found"
		ERR_LINK_FAILED:
			return "Link failed"
		ERR_SCRIPT_FAILED:
			return "Script failed"
		ERR_CYCLIC_LINK:
			return "Cyclic link"
		ERR_INVALID_DECLARATION:
			return "Invalid declaration"
		ERR_DUPLICATE_SYMBOL:
			return "Duplicate symbol"
		ERR_PARSE_ERROR:
			return "Parse error"
		ERR_BUSY:
			return "Busy"
		ERR_SKIP:
			return "Skip"
		ERR_HELP:
			return "Help"
		ERR_BUG:
			return "Bug"
		ERR_PRINTER_ON_FIRE:
			return "Printer on fire"

	return ""
