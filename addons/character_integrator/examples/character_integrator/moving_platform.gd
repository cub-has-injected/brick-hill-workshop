class_name MovingPlatform
extends RigidBody

var _ticks: = 0.0

func _integrate_forces(state:PhysicsDirectBodyState)->void :
	_ticks += state.step
	state.transform.origin.x = sin(_ticks) * 10.0
