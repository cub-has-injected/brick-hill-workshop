class_name DragBandboxManager
extends ViewportInputManagerTree

func _notification(what:int)->void :
	var scope = Profiler.scope(self, "_notification", [what])

	if what == NOTIFICATION_WM_FOCUS_OUT:
		var bandbox_selector = WorkshopDirectory.bandbox_selector()
		if bandbox_selector.selecting:
			bandbox_selector.end_selection()

func _unhandled_input(event:InputEvent)->void :
	var scope = Profiler.scope(self, "_unhandled_input", [event])

	if event is InputEventKey:
		if event.scancode == KEY_ALT:
			if not event.pressed:
				var bandbox_selector = WorkshopDirectory.bandbox_selector()
				if bandbox_selector.selecting:
					bandbox_selector.end_selection()
					return 

	if Input.is_key_pressed(KEY_ALT):
		WorkshopDirectory.bandbox_selector().handle_input(event)
