extends Node

enum CameraMode{
	Centered, 
	RightShoulder, 
	LeftShoulder
}

export (NodePath) var player_controller_path
export (NodePath) var camera_rig_path
export (NodePath) var character_rig_path

var min_distance: = 6.0
var max_distance: = 24.0
var camera_mode:int = CameraMode.Centered setget set_camera_mode

var _target_camera_offset: = Vector3.ZERO

func set_camera_mode(new_camera_mode:int)->void :
	var scope = Profiler.scope(self, "set_camera_mode", [new_camera_mode])

	if camera_mode != new_camera_mode:
		camera_mode = new_camera_mode
		update_camera_mode()

func update_camera_mode()->void :
	var scope = Profiler.scope(self, "update_camera_mode", [])

	var camera_rig = get_camera_rig()
	assert (camera_rig)

	match camera_mode:
		CameraMode.Centered:
			_target_camera_offset = Vector3.ZERO
			camera_rig.position_spring_tightness = 10.0
		CameraMode.RightShoulder:
			_target_camera_offset = Vector3(2, 1, 0)
			camera_rig.position_spring_tightness = 100.0
		CameraMode.LeftShoulder:
			_target_camera_offset = Vector3( - 2, 1, 0)
			camera_rig.position_spring_tightness = 100.0


func get_player_controller()->PlayerController:
	var scope = Profiler.scope(self, "get_player_controller", [])

	if not has_node(player_controller_path):
		return null

	return get_node(player_controller_path) as PlayerController

func get_camera_rig()->CameraRig:
	var scope = Profiler.scope(self, "get_camera_rig", [])

	if not has_node(camera_rig_path):
		return null

	return get_node(camera_rig_path) as CameraRig

func get_character_rig()->RigidBody:
	var scope = Profiler.scope(self, "get_character_rig", [])

	if not has_node(character_rig_path):
		return null

	return get_node(character_rig_path) as RigidBody

func _unhandled_input(event:InputEvent)->void :
	var scope = Profiler.scope(self, "_unhandled_input", [event])

	if Engine.is_editor_hint():
		return 

	if event.is_echo():
		return 

	var character_rig = get_character_rig()
	assert (character_rig)

	if event.is_action("camera_zoom_in"):
		if event.pressed:
			zoom( - 1)
	elif event.is_action("camera_zoom_out"):
		if event.pressed:
			zoom(1)
	elif event.is_action("camera_mode_next"):
		if event.pressed:
			match camera_mode:
				CameraMode.Centered:
					set_camera_mode(CameraMode.RightShoulder)
				CameraMode.RightShoulder:
					set_camera_mode(CameraMode.LeftShoulder)
				CameraMode.LeftShoulder:
					set_camera_mode(CameraMode.Centered)
	elif event.is_action("camera_mode_prev"):
		if event.pressed:
			match camera_mode:
				CameraMode.Centered:
					set_camera_mode(CameraMode.LeftShoulder)
				CameraMode.RightShoulder:
					set_camera_mode(CameraMode.Centered)
				CameraMode.LeftShoulder:
					set_camera_mode(CameraMode.RightShoulder)

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	var camera_rig = get_camera_rig()
	assert (camera_rig)
	camera_rig.local_offset = lerp(camera_rig.local_offset, _target_camera_offset, 5.0 * delta)

func zoom(delta:int)->void :
	var scope = Profiler.scope(self, "zoom", [delta])

	var camera_rig = get_camera_rig()
	assert (camera_rig)

	camera_rig.target_distance = clamp(camera_rig.target_distance + delta, min_distance, max_distance)
