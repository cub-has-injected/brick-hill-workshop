class_name ViewportInputManagerTree
extends FSMTree


func viewport_input(event:InputEvent)->void :
	var scope = Profiler.scope(self, "viewport_input", [event])

	for manager in get_global_states():
		if manager.has_method("viewport_input"):
			manager.viewport_input(event)

	var modal_manager = get_modal_state()
	if modal_manager:
		if modal_manager.has_method("viewport_input"):
			modal_manager.viewport_input(event)

func pickable_input(pickable:Node, camera:Object, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int)->void :
	var scope = Profiler.scope(self, "pickable_input", [pickable, camera, event, click_position, click_normal, shape_idx])

	for manager in get_global_states():
		if manager.has_method("pickable_input"):
			manager.pickable_input(pickable, camera, event, click_position, click_normal, shape_idx)

	var modal_manager = get_modal_state()
	if modal_manager:
		if modal_manager.has_method("pickable_input"):
			modal_manager.pickable_input(pickable, camera, event, click_position, click_normal, shape_idx)
