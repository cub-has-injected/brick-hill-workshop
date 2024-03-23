class_name DragManager
extends ViewportInputManagerTree

enum State{
	NONE, 
	MOVE, 
	BANDBOX
}

export (State) var state: = State.MOVE setget set_state

func set_state(new_state:int)->void :
	var scope = Profiler.scope(self, "set_state", [new_state])

	if state != new_state:
		state = new_state
		_set_state(state)

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	_set_state(state)

func get_modal_state_impl(modal:Node)->Node:
	var scope = Profiler.scope(self, "get_modal_state_impl", [modal])

	match _state:
		State.MOVE:
			return modal.get_node_or_null("DragMoveManager")
		State.BANDBOX:
			return modal.get_node_or_null("DragBandboxManager")
	return null

func _input(event:InputEvent)->void :
	var scope = Profiler.scope(self, "_input", [event])

	if event is InputEventKey:
		if event.scancode == KEY_ALT:
			match _state:
				State.MOVE:
					if event.pressed and not event.is_echo():
						set_state(State.BANDBOX)
				State.BANDBOX:
					if not event.pressed:
						set_state(State.MOVE)
