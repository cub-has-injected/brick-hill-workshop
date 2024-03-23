class_name FSMTree
extends Node



var _state:int = - 1 setget _set_state

func _set_state(new_state:int)->void :
	var scope = Profiler.scope(self, "_set_state", [new_state])

	if _state != new_state:
		exit_modal_state()
		_state = new_state
		enter_modal_state()

func enter_modal_state()->void :
	var scope = Profiler.scope(self, "enter_modal_state", [])

	var modal_node = get_modal_state()
	if not modal_node:
		return 

	if modal_node.has_method("enter_modal_state"):
		modal_node.enter_modal_state()

func exit_modal_state()->void :
	var scope = Profiler.scope(self, "exit_modal_state", [])

	var modal_node = get_modal_state()
	if not modal_node:
		return 

	if modal_node.has_method("exit_modal_state"):
		modal_node.exit_modal_state()

func get_global_states()->Array:
	var scope = Profiler.scope(self, "get_global_states", [])

	return get_global_states_impl()

func get_global_states_impl()->Array:
	var scope = Profiler.scope(self, "get_global_states_impl", [])

	var global = get_node_or_null("Global")
	if global:
		return global.get_children()
	else :
		return []

func get_modal_state()->Node:
	var scope = Profiler.scope(self, "get_modal_state", [])

	var modal_node = get_node_or_null("Modal")
	if modal_node:
		return get_modal_state_impl(modal_node)
	else :
		return null

func get_modal_state_impl(parent:Node)->Node:
	var scope = Profiler.scope(self, "get_modal_state_impl", [parent])

	return null
