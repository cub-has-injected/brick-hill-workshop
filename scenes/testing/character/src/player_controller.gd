class_name PlayerController
extends Spatial
tool 

const HALF_PI = PI * 0.5

var target_paths: = [
	NodePath("../CharacterRig"), 
	NodePath("../CameraRig")
]

var move_sensitivity: = Vector3.ONE
var camera_sensitivity: = Vector2.ONE

export (Vector2) var look_rotation: = Vector2.ZERO setget set_look_rotation, get_look_rotation

var input_map: = BrickHillInput.Actions.duplicate(true)

var _wish_scalar_left: = 0.0
var _wish_scalar_right: = 0.0
var _wish_scalar_up: = 0.0
var _wish_scalar_down: = 0.0
var _wish_scalar_forward: = 0.0
var _wish_scalar_backward: = 0.0

var _camera_wish_vector: = Vector2.ZERO

func set_look_rotation(new_look_rotation:Vector2)->void :
	new_look_rotation.x = deg2rad(new_look_rotation.x)
	new_look_rotation.y = deg2rad(new_look_rotation.y)

	if look_rotation != new_look_rotation:
		look_rotation = new_look_rotation

func get_look_rotation()->Vector2:
	return Vector2(rad2deg(look_rotation.x), rad2deg(look_rotation.y))

func _enter_tree()->void :
	if not Engine.is_editor_hint():
		var euler = global_transform.basis.get_euler()
		look_rotation.x += euler.y
		look_rotation.y += euler.x

func _process(delta:float)->void :
	if Engine.is_editor_hint():
		return 

	
	emit_look_event(Vector2(_camera_wish_vector) * InputSettings.pad_sensitivity * delta)

	for target_path in target_paths:
		var target = get_node(target_path)
		assert (target)

		if target.has_method("set_wish_vector"):
			target.set_wish_vector(get_local_wish_vector())

		if target.has_method("set_look_rotation"):
			target.set_look_rotation(look_rotation)

func get_forward_vector()->Vector3:
	var forward_vector = Vector3.FORWARD
	forward_vector = forward_vector.rotated(Vector3.UP, look_rotation.x)
	forward_vector = forward_vector.rotated(Vector3.UP.cross(forward_vector).normalized(), look_rotation.y)
	return forward_vector.normalized()

func get_local_wish_vector()->Vector3:
	return Vector3(
		- _wish_scalar_left + _wish_scalar_right, 
		- _wish_scalar_down + _wish_scalar_up, 
		- _wish_scalar_forward + _wish_scalar_backward
	) * move_sensitivity

func get_lateral_wish_vector_local()->Vector3:
	var lateral_wish_vector = get_local_wish_vector()
	lateral_wish_vector.y = 0.0
	return lateral_wish_vector

func get_lateral_wish_vector_global()->Vector3:
	return get_lateral_wish_vector_local().rotated(Vector3.UP, look_rotation.x)

func emit_look_event(relative:Vector2)->void :
	if relative.x != 0:
		var horizontal_action = InputEventAction.new()
		horizontal_action.action = "look_left" if relative.x < 0 else "look_right"
		horizontal_action.strength = abs(relative.x)
		Input.parse_input_event(horizontal_action)

	if relative.y != 0:
		var vertical_action = InputEventAction.new()
		vertical_action.action = "look_up" if relative.y < 0 else "look_down"
		vertical_action.strength = abs(relative.y)
		Input.parse_input_event(vertical_action)

func _get_event_strength(event:InputEvent, input_action:String)->float:
	var action = event.get("action")
	if action == input_action:
		var strength = event.get("strength")
		if strength != null:
			return strength

	return Input.get_action_strength(input_action)

func _unhandled_input(event:InputEvent)->void :
	if event.is_echo():
		get_tree().set_input_as_handled()
		return 

	var handled = false
	if event is InputEventMouseButton:
		if event.is_action("look_shift"):
			if event.pressed:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else :
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event is InputEventMouseMotion:
		
		if Input.is_action_pressed("look_shift"):
			emit_look_event(
				event.relative * InputSettings.mouse_sensitivity * Vector2(
					1.0 / GraphicsSettings.data.resolution_scale_factor, 
					1.0 / GraphicsSettings.data.resolution_scale_factor
				)
			)
			handled = true
	elif event.is_action("pad_look_left") or event.is_action("pad_look_right"):
		
		_camera_wish_vector.x = - event.get_action_strength("pad_look_left") + event.get_action_strength("pad_look_right")
		_camera_wish_vector.x = pow(abs(_camera_wish_vector.x), InputSettings.pad_camera_curve.x) * sign(_camera_wish_vector.x)
		handled = true
	elif event.is_action("pad_look_up") or event.is_action("pad_look_down"):
		
		_camera_wish_vector.y = - event.get_action_strength("pad_look_up") + event.get_action_strength("pad_look_down")
		_camera_wish_vector.y = pow(abs(_camera_wish_vector.y), InputSettings.pad_camera_curve.y) * sign(_camera_wish_vector.y)
		handled = true
	elif ( not input_map.Move.Left.empty() and event.is_action(input_map.Move.Left)) or ( not input_map.Move.Right.empty() and event.is_action(input_map.Move.Right)):
		_wish_scalar_left = _get_event_strength(event, input_map.Move.Left)
		_wish_scalar_right = _get_event_strength(event, input_map.Move.Right)
		handled = true
	elif ( not input_map.Move.Up.empty() and event.is_action(input_map.Move.Up)) or ( not input_map.Move.Down.empty() and event.is_action(input_map.Move.Down)):
		_wish_scalar_up = _get_event_strength(event, input_map.Move.Down)
		_wish_scalar_down = _get_event_strength(event, input_map.Move.Up)
		handled = true
	elif ( not input_map.Move.Forward.empty() and event.is_action(input_map.Move.Forward)) or ( not input_map.Move.Backward.empty() and event.is_action(input_map.Move.Backward)):
		_wish_scalar_forward = _get_event_strength(event, input_map.Move.Forward)
		_wish_scalar_backward = _get_event_strength(event, input_map.Move.Backward)
		handled = true
	elif ( not input_map.Look.Left.empty() and event.is_action(input_map.Look.Left)) or ( not input_map.Look.Right.empty() and event.is_action(input_map.Look.Right)):
		var delta = _get_event_strength(event, input_map.Look.Left) * camera_sensitivity.x - _get_event_strength(event, input_map.Look.Right) * camera_sensitivity.x
		look_rotation.x += delta
		handled = true
	elif ( not input_map.Look.Up.empty() and event.is_action(input_map.Look.Up)) or ( not input_map.Look.Down.empty() and event.is_action(input_map.Look.Down)):
		var delta = _get_event_strength(event, input_map.Look.Up) * camera_sensitivity.y - _get_event_strength(event, input_map.Look.Down) * camera_sensitivity.y
		look_rotation.y += delta
		look_rotation.y = clamp(look_rotation.y, - HALF_PI, HALF_PI)
		handled = true
	else :
		for target_path in target_paths:
			var target = get_node(target_path)
			assert (target)
			if target.has_method("unhandled_input"):
				target.unhandled_input(event)

	if handled:
		get_tree().set_input_as_handled()

func _get(property:String):
	var input_dictionary = _get_input_dictionary()
	var input_map_dictionary = _get_input_map_dictionary()

	if property.substr(0, "move/".length()) == "move/":
		var key = property.substr("move/".length(), - 1)
		return input_dictionary.values().find(input_map_dictionary["Move" + key.capitalize()])

	if property.substr(0, "look/".length()) == "look/":
		var key = property.substr("look/".length(), - 1)
		return input_dictionary.values().find(input_map_dictionary["Look" + key.capitalize()])

	return null

func _set(property:String, value):
	var input_dictionary = _get_input_dictionary()

	if property.substr(0, "move/".length()) == "move/":
		var key = property.substr("move/".length(), - 1).capitalize()
		input_map.Move[key] = input_dictionary[input_dictionary.keys()[value]]

	if property.substr(0, "look/".length()) == "look/":
		var key = property.substr("look/".length(), - 1).capitalize()
		input_map.Look[key] = input_dictionary[input_dictionary.keys()[value]]

func _get_property_list()->Array:
	var property_list: = []

	property_list.append({
		"name":"PlayerController", 
		"type":TYPE_STRING, 
		"usage":PROPERTY_USAGE_CATEGORY, 
	})

	property_list.append({
		"name":"target_paths", 
		"type":TYPE_ARRAY, 
		"hint":PropertyUtil.PROPERTY_HINT_TYPE_STRING, 
		"hint_string":PropertyUtil.array_hint_string(TYPE_NODE_PATH, TYPE_NIL, "")
	})

	property_list.append({
		"name":"Axes", 
		"type":TYPE_STRING, 
		"usage":PROPERTY_USAGE_GROUP, 
	})

	property_list.append({
		"name":"move_sensitivity", 
		"type":TYPE_VECTOR3
	})

	property_list.append({
		"name":"camera_sensitivity", 
		"type":TYPE_VECTOR2
	})

	property_list.append({
		"name":"look_rotation", 
		"type":TYPE_VECTOR2
	})

	property_list.append({
		"name":"Axes/Bindings", 
		"type":TYPE_STRING, 
		"usage":PROPERTY_USAGE_GROUP, 
	})

	var input_dictionary = _get_input_dictionary()
	for key in BrickHillInput.Actions.Move:
		property_list.append({
			"name":"move/" + key.to_lower(), 
			"type":TYPE_INT, 
			"hint":PROPERTY_HINT_ENUM, 
			"hint_string":PoolStringArray(input_dictionary.keys()).join(",")
		})

	for key in BrickHillInput.Actions.Look:
		property_list.append({
			"name":"look/" + key.to_lower(), 
			"type":TYPE_INT, 
			"hint":PROPERTY_HINT_ENUM, 
			"hint_string":PoolStringArray(input_dictionary.keys()).join(",")
		})

	property_list.append({
		"name":"input_map", 
		"type":TYPE_DICTIONARY, 
		"usage":PROPERTY_USAGE_NOEDITOR
	})

	return property_list

func _get_input_dictionary()->Dictionary:
	var input_dictionary: = {
		"[None]":""
	}
	for key in BrickHillInput.Actions.Move:
		input_dictionary["Move" + key] = BrickHillInput.Actions.Move[key]
	for key in BrickHillInput.Actions.Look:
		input_dictionary["Look" + key] = BrickHillInput.Actions.Look[key]
	return input_dictionary

func _get_input_map_dictionary()->Dictionary:
	var input_dictionary: = {
		"[None]":""
	}
	for key in input_map.Move:
		input_dictionary["Move" + key] = input_map.Move[key]
	for key in input_map.Look:
		input_dictionary["Look" + key] = input_map.Look[key]
	return input_dictionary
