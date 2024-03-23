extends Spatial

var turn_speed = 10.0
var walk_speed_factor = 10.0

var prev_grounded: = false
var draw_debug: = true


func get_rigid_body()->RigidBody:
	return get_node_or_null("CharacterRig") as RigidBody


func set_avatar_data(new_avatar_data:AvatarData)->void :
	#$PhysicsLerpRemoteTransform / GameAvatarRig.set_avatar_data(new_avatar_data)
	print("bo")

func _physics_process(delta:float)->void :
	var grounded = $CharacterRig.integrator.grounded

	var wv = $CharacterRig.integrator.get_global_wish_vector()
	var target_basis:Basis
	var update_basis: = true
	if $DefaultPlayerScript.camera_mode == 0:
		if wv.length() > 0.01:
			target_basis = Basis.IDENTITY.rotated(Vector3.UP, atan2(wv.x, wv.z) - PI)
		else :
			update_basis = false
	else :
		target_basis = Basis.IDENTITY.rotated(Vector3.UP, deg2rad($PlayerController.look_rotation.x))

	if update_basis:
		$PhysicsLerpRemoteTransform / GameAvatarRig.global_transform.basis = $PhysicsLerpRemoteTransform / GameAvatarRig.global_transform.basis.orthonormalized().slerp(target_basis, turn_speed * delta)

	if grounded and prev_grounded:
		var lv = $CharacterRig.integrator.get_global_lateral_velocity()
		if lv.length() > 0.01:
			$PhysicsLerpRemoteTransform / GameAvatarRig.set_walking(lv.length() * delta * walk_speed_factor)
		else :
			$PhysicsLerpRemoteTransform / GameAvatarRig.set_idle()
	elif grounded and not prev_grounded:
		$PhysicsLerpRemoteTransform / GameAvatarRig.set_landing()
	elif not grounded and not prev_grounded:
		var v = $CharacterRig.linear_velocity
		if $CharacterRig.global_transform.basis.y.dot(v) > 0.0:
			$PhysicsLerpRemoteTransform / GameAvatarRig.set_jumping()
		else :
			$PhysicsLerpRemoteTransform / GameAvatarRig.set_falling()

	prev_grounded = grounded

	if draw_debug:
		var debug_geo = $DebugGeometry / ImmediateGeometry as ImmediateGeometry
		$CharacterRig.integrator.draw_debug(debug_geo, $CharacterRig.global_transform.origin)
