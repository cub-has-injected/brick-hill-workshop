extends RigidBody

"\nTODO\n- Use separate collision checks for ground basis and ground velocity (velocity should be smaller)\n\n- Fix intermittent freezing caused by invalid physics API usage\n	- Best approach for now is to place asserts in all body state calls\n	- This may actually be tied to inadvertently firing visual updates from the physics thread\n\n- Prevent step up/down from adding velocity\n- Prevent step up/down from happening when traversing slopes\n\n- Implement coyote time\n	- Use a sized buffer instead of _prev for grounded / ground basis caching\n		- Update each physics frame, remove old entries if over size limit\n	- If any entry in the buffer is true, character is grounded\n		- Need to clear buffer on jump to immediately clear grounded state\n"

export (Resource) var integrator:Resource = null

export (NodePath) var target_basis_path: = NodePath()
export (NodePath) var camera_anchor_path: = NodePath()

var wish_vector_binds: = {
	KEY_W:Vector3.FORWARD, 
	KEY_S:Vector3.BACK, 
	KEY_A:Vector3.LEFT, 
	KEY_D:Vector3.RIGHT
}

var _wish_vector: = Vector3.ZERO

func get_target_basis()->Spatial:
	return get_node_or_null(target_basis_path) as Spatial

func get_camera_anchor()->Spatial:
	return get_node_or_null(camera_anchor_path) as Spatial

func _ready()->void :
	
	var shape_owner = create_shape_owner(self)
	shape_owner_add_shape(shape_owner, integrator.main_shape)

	integrator.exclude = [self]
	integrator.collision_mask = collision_mask

func _process(delta:float)->void :
	integrator.process(delta, linear_velocity)

	if integrator.stepped_down:
		print("%s - Stepped down" % [OS.get_ticks_msec()])
		integrator.stepped_down = false

	if integrator.stepped_up:
		print("%s - Stepped up" % [OS.get_ticks_msec()])
		integrator.stepped_up = false

func _unhandled_key_input(event:InputEventKey)->void :
	if event.scancode == KEY_SPACE and not event.is_echo():
		integrator.jump_buffered = event.pressed

func _integrate_forces(state:PhysicsDirectBodyState)->void :
	_wish_vector = Vector3.ZERO

	for bind in wish_vector_binds:
		if Input.is_key_pressed(bind):
			_wish_vector += wish_vector_binds[bind]

	_wish_vector = _wish_vector.normalized()

	integrator.wish_vector = _wish_vector

	integrator.target_basis = get_target_basis().global_transform.basis

	integrator.integrate_forces(state)

	
	var camera_anchor = get_camera_anchor()
	if camera_anchor:
		var trx = state.transform
		camera_anchor.global_transform = state.transform.translated(global_transform.basis.xform_inv(integrator.step_offset))
