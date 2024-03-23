class_name StateMachine

const PRINT_DEBUG: = false
const TRANSITION_NONE: = - 1

enum EventType{
	Entry, 
	Exit, 
	Process, 
	PhysicsProcess, 
	Input, 
	UnhandledInput
}

var _states: = {}
var _super_states: = {}
var _super_state_table: = {}
var _initial_state:int
var _state:int = - 1

var _state_events: = {
	EventType.Entry:{}, 
	EventType.Exit:{}, 
	EventType.Process:{}, 
	EventType.PhysicsProcess:{}, 
	EventType.Input:{}, 
	EventType.UnhandledInput:{}
}

var _super_state_events: = {
	EventType.Entry:{}, 
	EventType.Exit:{}, 
	EventType.Process:{}, 
	EventType.PhysicsProcess:{}, 
	EventType.Input:{}, 
	EventType.UnhandledInput:{}
}

func _init(states:Dictionary, super_states:Dictionary, super_state_table:Dictionary, in_initial_state:int)->void :
	_states = states
	_super_states = super_states
	_super_state_table = super_state_table
	_initial_state = in_initial_state

func register_state_event(event_type:int, state:int, instance:Object, method:String)->void :
	assert (event_type in _state_events)
	_state_events[event_type][state] = funcref(instance, method)

func register_super_state_event(event_type:int, super_state:int, instance:Object, method:String)->void :
	assert (event_type in _super_state_events)
	_super_state_events[event_type][super_state] = funcref(instance, method)

func get_state()->int:
	return _state

func get_super_state()->int:
	for key in _super_state_table:
		if _state in _super_state_table[key]:
			return key
	return - 1

func run()->void :
	set_state(_initial_state)

func set_state(new_state:int)->void :
	assert (new_state in _states.values())
	if _state != new_state:
		if _state != - 1:
			_exit()

		_state = new_state

		if _state != - 1:
			if PRINT_DEBUG:
				print_debug("Transition to %s" % [_states.keys()[_states.values().find(_state)]])
			_enter()

func _handle_event(event_dict:Dictionary, event_type:int, state:int, args:Array = [])->void :
	if state == - 1:
		return 

	if not state in event_dict[event_type]:
		return 

	event_dict[event_type][state].call_funcv(args)

func _enter()->void :
	_handle_event(_state_events, EventType.Entry, _state)
	_handle_event(_super_state_events, EventType.Entry, get_super_state())

func _exit()->void :
	_handle_event(_state_events, EventType.Exit, _state)
	_handle_event(_super_state_events, EventType.Exit, get_super_state())

func process(delta:float)->void :
	_handle_event(_state_events, EventType.Process, _state, [delta])
	_handle_event(_super_state_events, EventType.Process, get_super_state(), [delta])

func physics_process(delta:float)->void :
	_handle_event(_state_events, EventType.PhysicsProcess, _state, [delta])
	_handle_event(_super_state_events, EventType.PhysicsProcess, get_super_state(), [delta])

func input(event:InputEvent)->void :
	_handle_event(_state_events, EventType.Input, _state, [event])
	_handle_event(_super_state_events, EventType.Input, get_super_state(), [event])

func unhandled_input(event:InputEvent)->void :
	_handle_event(_state_events, EventType.UnhandledInput, _state, [event])
	_handle_event(_super_state_events, EventType.UnhandledInput, get_super_state(), [event])
