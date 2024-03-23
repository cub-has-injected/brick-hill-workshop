extends Node

signal on_action_do(action)
signal on_action_undo(action)

enum State{
	Default, 
	UndoComposite, 
	RedoComposite, 
}

var undo_queue: = []
var redo_queue: = []
var state:int = State.Default




func undo()->void :
	var scope = Profiler.scope(self, "undo")

	while undo_queue.size() > 0:
		var action = undo_queue.pop_back()
		assert (action)

		redo_queue.push_front(action)

		if action is EndCompositeAction:
			assert (state == State.Default, "Encountered an EndCompositeAction while undoing a composite action")
			state = State.UndoComposite
		elif action is BeginCompositeAction:
			assert (state == State.UndoComposite, "Encountered a BeginCompositeAction while not undoing a composite action")
			state = State.Default
		else :
			undo_action(action)

		if state == State.Default:
			break

func redo()->void :
	var scope = Profiler.scope(self, "redo")

	while redo_queue.size() > 0:
		var action = redo_queue.pop_front()
		assert (action)

		undo_queue.push_back(action)

		if action is BeginCompositeAction:
			assert (state == State.Default, "Encountered a BeginCompositeAction while while redoing a composite action")
			state = State.RedoComposite
		elif action is EndCompositeAction:
			assert (state == State.RedoComposite)
			state = State.Default
		else :
			do_action(action)

		if state == State.Default:
			break

func clear()->void :
	var scope = Profiler.scope(self, "clear")

	undo_queue.clear()
	redo_queue.clear()

func execute_action(action)->void :
	var scope = Profiler.scope(self, "execute_action", [action])

	
	undo_queue.append(action)
	redo_queue.clear()
	do_action(action)

func do_action(action)->void :
	var scope = Profiler.scope(self, "do_action", [action])

	action.validate_state()
	action.do()
	emit_signal("on_action_do", action)

func undo_action(action)->void :
	var scope = Profiler.scope(self, "undo_action", [action])

	action.validate_state()
	action.undo()
	emit_signal("on_action_undo", action)
