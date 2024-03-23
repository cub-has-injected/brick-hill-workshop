class_name PhysicsInterpolator
extends Spatial

export (bool) var active: = true setget set_active

func set_active(new_active:bool)->void :
	var scope = Profiler.scope(self, "set_active", [new_active])

	if active != new_active:
		active = new_active
		update_active()

var _from_transform: = Transform.IDENTITY
var _from_ticks_usec: = 0.0

var _to_transform: = Transform.IDENTITY

func update_active()->void :
	var scope = Profiler.scope(self, "update_active", [])

	set_ticking(active)
	if not active:
		transform = Transform.IDENTITY

func set_ticking(ticking:bool)->void :
	set_process(active)
	set_physics_process(active)

func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	_from_transform = global_transform
	_from_ticks_usec = OS.get_ticks_usec()

	_to_transform = global_transform

	update_active()

func _physics_process(delta:float)->void :
	var scope = Profiler.scope(self, "_physics_process", [delta])

	_from_transform = _to_transform
	_from_ticks_usec = OS.get_ticks_usec()

	_to_transform = global_transform

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	var us_delta = OS.get_ticks_usec() - _from_ticks_usec
	var ms_delta = us_delta * 0.001
	var ms_per_frame = 1000.0 / Engine.iterations_per_second
	var timestamp_delta = ms_delta / ms_per_frame

	for child in get_children():
		child.global_transform = _from_transform.interpolate_with(_to_transform, timestamp_delta)
