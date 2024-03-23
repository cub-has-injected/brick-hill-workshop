extends CollisionShape
tool 

func _process(delta:float)->void :
	var radius = 1.0
	var target_distance = 6.0

	var basis = Basis.IDENTITY
	var rest_query = PhysicsShapeQueryParameters.new()
	var rest_trx = Transform.IDENTITY
	rest_trx = rest_trx.looking_at(basis.z * target_distance, Vector3.UP)
	rest_trx.origin = get_parent().global_transform.origin
	rest_trx.basis = rest_trx.basis.scaled(Vector3(radius * 2.0, target_distance, radius * 2.0))
	rest_trx = rest_trx.rotated(rest_trx.basis.x.normalized(), PI * 0.5)
	rest_trx.origin += basis.z * target_distance * 0.5
	rest_trx = rest_trx.rotated(rest_trx.basis.x.normalized(), deg2rad(30.0))
	global_transform = rest_trx
