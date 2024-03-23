extends Spatial

func _unhandled_input(event:InputEvent)->void :
	if not Input.is_mouse_button_pressed(BUTTON_RIGHT):
		return 

	if event is InputEventMouseMotion:
		rotate_object_local(Vector3.LEFT, event.relative.y * 0.004)
		rotation_degrees.x = clamp(rotation_degrees.x, - 90, 90)
