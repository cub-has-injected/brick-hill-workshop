extends Spatial

func _unhandled_input(event:InputEvent)->void :
	if not Input.is_mouse_button_pressed(BUTTON_RIGHT):
		return 

	if event is InputEventMouseMotion:
		rotate_object_local(Vector3.DOWN, event.relative.x * 0.004)
