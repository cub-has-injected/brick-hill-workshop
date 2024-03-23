class_name TraceTree
extends Tree

const COLUMN_CONTEXT = 0
const COLUMN_NAME = 1
const COLUMN_PARAMS = 2
const COLUMN_DURATION = 3

const TARGET_FRAMETIME_MS = 1000.0 / 30.0

var _bg_gradient:Gradient = null
var _fg_gradient:Gradient = null

func _init()->void :
	_bg_gradient = load("res://addons/profiling/resources/gradient_bg.tres")
	_fg_gradient = load("res://addons/profiling/resources/gradient_fg.tres")

	columns = 4
	set_column_titles_visible(true)
	set_column_title(COLUMN_CONTEXT, "Context")
	set_column_title(COLUMN_NAME, "Name")
	set_column_title(COLUMN_PARAMS, "Params")
	set_column_title(COLUMN_DURATION, "Duration")
	Profiler.connect("scope_opened", self, "scope_opened")
	Profiler.connect("scope_closed", self, "scope_closed")
	Profiler.connect("cleared", self, "profiler_cleared")

var scope_stacks: = {}
var thread_items: = {}

func profiler_cleared()->void :
	scope_stacks.clear()
	thread_items.clear()
	clear()

func scope_opened(id:int, timestamp:int)->void :
	var data = Profiler.data(id)

	if not data.thread_id in scope_stacks:
		scope_stacks[data.thread_id] = []
		var thread_item = create_item()
		thread_item.set_text(0, String(data.thread_id))
		thread_items[data.thread_id] = thread_item

	var scope_stack = scope_stacks[data.thread_id]
	var thread_item = thread_items[data.thread_id]

	var scope_item:TreeItem
	if scope_stack.size() == 0:
		scope_item = create_item(thread_item)
	else :
		scope_item = create_item(scope_stack[ - 1])

	scope_item.set_metadata(0, data)
	scope_item.set_metadata(1, timestamp)
	scope_item.set_text(COLUMN_CONTEXT, data.context)
	scope_item.set_text(COLUMN_NAME, data.name)
	scope_item.set_text(COLUMN_PARAMS, data.params)
	scope_item.set_text(COLUMN_DURATION, "...")
	scope_item.set_collapsed(true)
	scope_stack.append(scope_item)

func scope_closed(id:int, timestamp:int)->void :
	var data = Profiler.data(id)
	if data.empty():
		
		return 

	var scope_stack = scope_stacks[data.thread_id]

	if scope_stack.size() == 0:
		
		return 

	var scope_item = scope_stack[ - 1]
	var scope_data:Dictionary = scope_item.get_metadata(0);
	if not id == scope_data.id:
		
		return 

	var open_timestamp:int = scope_item.get_metadata(1)
	var usec:int = timestamp - open_timestamp
	var msec = usec / 1000
	var sec = msec / 1000
	var msec_rem = msec % 1000
	var usec_rem = usec % 1000

	scope_item.set_text(COLUMN_DURATION, "%ssec, %sms, %sus" % [sec, msec_rem, usec_rem])
	scope_item.set_custom_bg_color(COLUMN_DURATION, _bg_gradient.interpolate(msec / TARGET_FRAMETIME_MS))
	scope_item.set_custom_color(COLUMN_DURATION, _fg_gradient.interpolate(msec / TARGET_FRAMETIME_MS))
	scope_stack.pop_back()
