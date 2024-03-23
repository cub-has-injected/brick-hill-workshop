extends Node
tool 

signal active_changed(active)
signal clear_on_process_changed(active)
signal scope_opened(id)
signal scope_closed(id)
signal cleared()

class ScopeOpen:
	var id:int
	var timestamp:int

	func _init(in_id:int, in_timestamp:int)->void :
		id = in_id
		timestamp = in_timestamp

class ScopeClose:
	var id:int
	var timestamp:int

	func _init(in_id:int, in_timestamp:int)->void :
		id = in_id
		timestamp = in_timestamp

var _scope_events: = {}
var _scope_data: = {}

var _active:bool = false setget set_active, active
var _clear_on_process:bool = false setget set_clear_on_process, clear_on_process
var _next_scope_id:int = 0

var _root_scope = null

var _name_filter = "" setget set_name_filter

static func stringify(object)->String:
	if object is Node:
		return "Node(%s)" % object.get_name()
	elif object is Resource:
		return "Resource(%s)" % object.get_name()
	elif object is Reference and object.has_method("get_name"):
		return "Reference(%s)" % object.get_name()
	elif object is Object and object.has_method("get_name"):
		return "Object(%s)" % object.get_name()
	else :
		return "%s" % [object]

func set_active(new_active:bool)->void :
	if _active != new_active:
		_active = new_active
		emit_signal("active_changed", _active)

func set_clear_on_process(new_clear_on_process:bool)->void :
	if _clear_on_process != new_clear_on_process:
		_clear_on_process = new_clear_on_process
		emit_signal("clear_on_process_changed", _clear_on_process)

func set_name_filter(new_name_filter:String)->void :
	if _name_filter != new_name_filter:
		_name_filter = new_name_filter
		print(_name_filter)

func toggle_active()->void :
	set_active( not _active)

func toggle_clear_on_process()->void :
	set_clear_on_process( not _clear_on_process)

func active()->bool:
	return _active

func clear_on_process()->bool:
	return _clear_on_process

func events()->Dictionary:
	return _scope_events

func data(id:int)->Dictionary:
	if id in _scope_data:
			return _scope_data[id]
	else :
		return {}

func scope(context:Object, name:String, params:Array = [])->Scope:
	var scope_id = _next_scope_id
	var scope = Scope.new()
	scope.id = scope_id
	scope.open = true

	if Engine.is_editor_hint() or not _active:
		return scope

	if not _name_filter.empty() and name.find(_name_filter) == - 1:
		return scope

	var thread_id = OS.get_thread_caller_id()

	if not thread_id in _scope_events:
		_scope_events[thread_id] = []


	var context_string = stringify(context)

	var params_string:String
	for param in params:
		params_string += "%s, " % stringify(param)

	_scope_data[scope.id] = {
		"id":scope_id, 
		"context":context_string, 
		"name":name, 
		"params":params_string, 
		"thread_id":thread_id, 
	}

	_next_scope_id += 1

	var timestamp = OS.get_ticks_usec()
	_scope_events[thread_id].append(ScopeOpen.new(scope_id, timestamp))
	emit_signal("scope_opened", scope.id, timestamp)

	return scope

func scope_close(scope_id:int):
	if Engine.is_editor_hint() or not _active:
		return 

	var thread_id = OS.get_thread_caller_id()
	if not thread_id in _scope_events:
		return 

	var timestamp = OS.get_ticks_usec()
	_scope_events[thread_id].append(ScopeClose.new(scope_id, timestamp))
	emit_signal("scope_closed", scope_id, _scope_events[thread_id][ - 1].timestamp)

func clear():
	_scope_events.clear()
	_scope_data.clear()
	_next_scope_id = 0
	emit_signal("cleared")

func _process(_delta:float)->void :
	if is_instance_valid(_root_scope):
		_root_scope.close()

	if _active and _clear_on_process:
		clear()

	_root_scope = scope(self, "Frame %s" % [Engine.get_frames_drawn()])
