extends Control
tool 

enum TestScenario{
	Walls, 
	Slopes, 
	Stairs, 
	WallOverhangs, 
	SlopeOverhangs, 
	HalfPipe, 
	OvalRoom, 
	Cylinder, 
	Cube
}

enum SpawnPattern{
	Circle, 
	Square, 
	Line, 
	Player
}

const SCENARIO_SCENES: = {
	TestScenario.Walls:preload("res://scenes/testing/instanced/physics_tests/Walls.tscn"), 
	TestScenario.Slopes:preload("res://scenes/testing/instanced/physics_tests/Slopes.tscn"), 
	TestScenario.Stairs:preload("res://scenes/testing/instanced/physics_tests/Stairs.tscn"), 
	TestScenario.WallOverhangs:preload("res://scenes/testing/instanced/physics_tests/WallOverhangs.tscn"), 
	TestScenario.SlopeOverhangs:preload("res://scenes/testing/instanced/physics_tests/SlopeOverhangs.tscn"), 
	TestScenario.HalfPipe:preload("res://scenes/testing/instanced/physics_tests/HalfPipe.tscn"), 
	TestScenario.OvalRoom:preload("res://scenes/testing/instanced/physics_tests/OvalRoom.tscn"), 
	TestScenario.Cylinder:preload("res://scenes/testing/instanced/physics_tests/Cylinder.tscn"), 
	TestScenario.Cube:preload("res://scenes/testing/instanced/physics_tests/Cube.tscn"), 
}

export (TestScenario) var test_scenario:int = TestScenario.Walls setget set_test_scenario
export (float) var ceiling_height: = 6.5 setget set_ceiling_height

export (SpawnPattern) var spawn_pattern:int = SpawnPattern.Circle setget set_spawn_pattern
export (int) var spawn_count: = 200 setget set_spawn_count
export (float) var spawn_radius: = 0.0 setget set_spawn_radius
export (float) var spawn_velocity: = 1.0 setget set_spawn_velocity
export (Vector3) var spawn_translation_offset: = Vector3.ZERO setget set_spawn_translation_offset
export (Vector3) var spawn_rotation_offset: = Vector3.ZERO setget set_spawn_rotation_offset
export (Vector3) var additional_spawn_velocity: = Vector3.DOWN setget set_additional_spawn_velocity

export (bool) var show_lateral: = true setget set_show_lateral
export (bool) var show_vertical: = true setget set_show_vertical
export (int) var slide_index: = 0 setget set_slide_index

var _physics_body_ex_scene: = preload("res://scenes/testing/instanced/PhysicsBodyEx.tscn")
var _physics_accuracy_tester_scene: = preload("res://scenes/testing/instanced/PhysicsAccuracyTester.tscn")
var _physics_tester_instances: = []
var _selected_instance:Node

var _test_scenario_instance:Spatial


func set_test_scenario(new_test_scenario:int)->void :
	if test_scenario != new_test_scenario:
		test_scenario = new_test_scenario
		test_scenario_changed()

func set_ceiling_height(new_ceiling_height:float)->void :
	if ceiling_height != new_ceiling_height:
		ceiling_height = new_ceiling_height
		ceiling_height_changed()

func set_spawn_pattern(new_spawn_pattern:int)->void :
	if spawn_pattern != new_spawn_pattern:
		spawn_pattern = new_spawn_pattern
		try_respawn_physics_testers()

func set_spawn_count(new_spawn_count:int)->void :
	if spawn_count != new_spawn_count:
		spawn_count = new_spawn_count
		try_respawn_physics_testers()

func set_spawn_radius(new_spawn_radius:float)->void :
	if spawn_radius != new_spawn_radius:
		spawn_radius = new_spawn_radius
		try_respawn_physics_testers()

func set_spawn_velocity(new_spawn_velocity:float)->void :
	if spawn_velocity != new_spawn_velocity:
		spawn_velocity = new_spawn_velocity
		try_respawn_physics_testers()

func set_spawn_translation_offset(new_spawn_translation_offset:Vector3)->void :
	if spawn_translation_offset != new_spawn_translation_offset:
		spawn_translation_offset = new_spawn_translation_offset
		try_respawn_physics_testers()

func set_spawn_rotation_offset(new_spawn_rotation_offset:Vector3)->void :
	if spawn_rotation_offset != new_spawn_rotation_offset:
		spawn_rotation_offset = new_spawn_rotation_offset
		try_respawn_physics_testers()

func set_additional_spawn_velocity(new_additional_spawn_velocity:Vector3)->void :
	if additional_spawn_velocity != new_additional_spawn_velocity:
		additional_spawn_velocity = new_additional_spawn_velocity
		try_respawn_physics_testers()

func set_selected_instance(new_selected_instance:Node)->void :
	if _selected_instance != new_selected_instance:
		if _selected_instance and _selected_instance.is_connected("stepped", self, "_update_debug_print"):
			_selected_instance.disconnect("stepped", self, "_update_debug_print")

		_selected_instance = new_selected_instance

		if _selected_instance and not _selected_instance.is_connected("stepped", self, "_update_debug_print"):
			_selected_instance.connect("stepped", self, "_update_debug_print")

		_selected_instance_changed()

func set_show_lateral(new_show_lateral:bool)->void :
	if show_lateral != new_show_lateral:
		show_lateral = new_show_lateral
		_update_debug_print()

func set_show_vertical(new_show_vertical:bool)->void :
	if show_vertical != new_show_vertical:
		show_vertical = new_show_vertical
		_update_debug_print()

func set_slide_index_float(new_slide_index:float)->void :
	set_slide_index(int(new_slide_index))

func set_slide_index(new_slide_index:int)->void :
	if slide_index != new_slide_index:
		slide_index = new_slide_index
		_update_debug_print()


func get_debug_print()->RichTextLabel:
	return $HBoxContainer / Panel / VBoxContainer / DebugPrint as RichTextLabel

func get_cameras()->Array:
	return [
		$HBoxContainer / Viewports / RightViewportContainer / Viewport / Camera, 
		$HBoxContainer / Viewports / TopViewportContainer / Viewport / Camera, 
		$HBoxContainer / Viewports / FrontViewportContainer / Viewport / Camera, 
		$HBoxContainer / Viewports / PerspectiveViewportContainer / Viewport / Camera, 
	]

func get_camera_rig()->Spatial:
	return $CameraRig as Spatial

func get_physics_testers()->Array:
	var physics_testers: = []
	for child in $PhysicsTesters.get_children():
		if child is KinematicBody:
			physics_testers.append(child)
	return physics_testers


func test_scenario_changed()->void :
	if is_inside_tree():
		var geometry_node: = $Geometry

		for child in geometry_node.get_children():
			if child.has_meta("physics_test_child"):
				geometry_node.remove_child(child)
				child.queue_free()

		var instance = SCENARIO_SCENES[test_scenario].instance()
		instance.set_meta("physics_test_child", true)
		geometry_node.add_child(instance)

func _selected_instance_changed()->void :
	_update_instance_visibility()
	_update_debug_print()

func ceiling_height_changed()->void :
	if is_inside_tree():
		var ceiling_node: = $Geometry / Ceiling
		ceiling_node.global_transform.origin.y = ceiling_height


func _ready()->void :
	test_scenario_changed()
	ceiling_height_changed()
	respawn_physics_testers()

func _unhandled_key_input(event:InputEventKey)->void :
	if event.pressed:
		match event.scancode:
			KEY_F:
				if _selected_instance:
					_selected_instance.queue_move(_selected_instance.debug_motion)
				else :
					for physics_tester in get_physics_testers():
						physics_tester.queue_move(physics_tester.debug_motion)
			KEY_D:
				if _selected_instance:
					_selected_instance.step_back()
				else :
					for physics_tester in get_physics_testers():
						physics_tester.step_back()
			KEY_ESCAPE:
				get_tree().quit()


func try_respawn_physics_testers()->void :
	if is_inside_tree():
		respawn_physics_testers()

func respawn_physics_testers()->void :
	var physics_testers_node: = $PhysicsTesters
	for child in physics_testers_node.get_children():
		if child.has_meta("physics_test_child"):
			physics_testers_node.remove_child(child)
			child.queue_free()

	match spawn_pattern:
		SpawnPattern.Circle:
			spawn_physics_testers_circle()
		SpawnPattern.Square:
			spawn_physics_testers_square()
		SpawnPattern.Line:
			spawn_physics_testers_line()
		SpawnPattern.Player:
			spawn_physics_tester_player()

func spawn_physics_testers_circle()->void :
	for i in range(0, spawn_count):
		var rad = (float(i) / float(spawn_count)) * TAU
		var norm = Vector3.FORWARD.rotated(Vector3.UP, rad)
		spawn_physics_tester(norm, norm * spawn_velocity)

func spawn_physics_testers_square()->void :
	var side_spawn_count = spawn_count / 4
	for x in range(0, spawn_count):
		var inc = float(x) / float(spawn_count - 1)
		inc -= 0.5
		inc *= 2.0
		inc *= spawn_radius
		spawn_physics_tester(Vector3(inc, 0, spawn_radius), Vector3(0, 0, spawn_velocity))
		spawn_physics_tester(Vector3(inc, 0, - spawn_radius), Vector3(0, 0, - spawn_velocity))
		spawn_physics_tester(Vector3(spawn_radius, 0, inc), Vector3(spawn_velocity, 0, 0))
		spawn_physics_tester(Vector3( - spawn_radius, 0, inc), Vector3( - spawn_velocity, 0, 0))

func spawn_physics_testers_line()->void :
	for x in range(0, spawn_count):
		var inc = float(x) / float(spawn_count - 1)
		inc -= 0.5
		inc *= 2.0
		inc *= spawn_radius
		spawn_physics_tester(Vector3(inc, 0, 0), Vector3(0, 0, - spawn_velocity))

func spawn_physics_tester_player()->KinematicBody:
	var physics_testers_node: = $PhysicsTesters

	var instance = _physics_accuracy_tester_scene.instance()
	instance.set_meta("physics_test_child", true)
	instance.connect("pressed", self, "_instance_pressed", [instance])

	instance.transform.origin += spawn_translation_offset * spawn_radius
	instance.transform = instance.transform.rotated(Vector3.RIGHT, deg2rad(spawn_rotation_offset.x))
	instance.transform = instance.transform.rotated(Vector3.UP, deg2rad(spawn_rotation_offset.y))
	instance.transform = instance.transform.rotated(Vector3.FORWARD, deg2rad(spawn_rotation_offset.z))

	physics_testers_node.add_child(instance)

	return instance

func spawn_physics_tester(offset:Vector3, motion:Vector3)->KinematicBody:
	var physics_testers_node: = $PhysicsTesters
	var instance = _physics_body_ex_scene.instance()
	instance.set_meta("physics_test_child", true)
	instance.connect("pressed", self, "_instance_pressed", [instance])
	_physics_tester_instances.append(instance)

	instance.transform.origin += spawn_translation_offset + offset * spawn_radius
	instance.transform = instance.transform.rotated(Vector3.RIGHT, deg2rad(spawn_rotation_offset.x))
	instance.transform = instance.transform.rotated(Vector3.UP, deg2rad(spawn_rotation_offset.y))
	instance.transform = instance.transform.rotated(Vector3.FORWARD, deg2rad(spawn_rotation_offset.z))

	instance.debug_motion = motion + additional_spawn_velocity
	instance.debug_motion = instance.transform.basis * instance.debug_motion

	physics_testers_node.add_child(instance)

	return instance

func _update_instance_visibility()->void :
	for child_instance in _physics_tester_instances:
		child_instance.set_visible(_selected_instance == null or child_instance == _selected_instance)

func _update_debug_print()->void :
	var debug_print = get_debug_print()
	assert (debug_print)

	for child_instance in _physics_tester_instances:
		var debug_geometry = child_instance.get_debug_draw()
		if debug_geometry:
			debug_geometry.clear()

	if _selected_instance:
		debug_print.bbcode_text = _selected_instance.get_debug_log(show_lateral, show_vertical, slide_index)
	else :
		debug_print.bbcode_text = ""

func _instance_pressed(instance:Node)->void :
	set_selected_instance(instance)

func viewport_input(event:InputEvent, index:int)->void :
	var cameras = get_cameras()

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				set_selected_instance(null)
		elif event.button_index == BUTTON_WHEEL_UP:
			if index < 3:
				for camera in cameras:
					camera.size = max(camera.size - 1.0, 0.1)
			else :
				cameras[3].global_transform.origin -= cameras[3].global_transform.basis.z
		elif event.button_index == BUTTON_WHEEL_DOWN:
			if index < 3:
				for camera in cameras:
					camera.size = min(camera.size + 1.0, 16384)
			else :
				cameras[3].global_transform.origin += cameras[3].global_transform.basis.z
	elif event is InputEventMouseMotion:
		if BUTTON_MASK_RIGHT & event.button_mask and index >= 3:
			cameras[3].rotation.y -= event.relative.x * 0.005
			cameras[3].rotation.x -= event.relative.y * 0.005
		elif BUTTON_MASK_RIGHT & event.button_mask or BUTTON_MASK_MIDDLE & event.button_mask:
			var camera = cameras[index]
			var pan_vector = - event.relative.x * camera.global_transform.basis.x + event.relative.y * camera.global_transform.basis.y
			var target_spatial:Spatial
			var scale_factor:float
			if index < 3:
				target_spatial = get_camera_rig()
				scale_factor = camera.size * 0.003
			else :
				target_spatial = camera
				scale_factor = 0.01
			target_spatial.global_transform.origin += pan_vector * scale_factor
