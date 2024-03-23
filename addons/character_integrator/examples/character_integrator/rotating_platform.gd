extends RigidBody

export (Vector3) var axis: = Vector3.RIGHT
export (float) var speed: = 1.0
export (bool) var sine: = true
var _ticks: = 0.0

func _integrate_forces(state:PhysicsDirectBodyState)->void :
	_ticks += state.step

	var rad = _ticks * speed
	if sine:
		rad = sin(rad)
	state.transform.basis = Basis(axis.normalized(), rad)
