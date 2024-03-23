class_name LinearMotionIntegrator
extends Integrator

var _move_buffer:Vector3

func buffer_move(delta:Vector3)->void :
	_move_buffer += delta

func _integrate_forces(state:PhysicsDirectBodyState)->void :
	
	state.linear_velocity = _move_buffer / state.step
	_move_buffer = Vector3.ZERO
