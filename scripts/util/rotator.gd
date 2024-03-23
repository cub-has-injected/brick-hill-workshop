class_name Rotator
extends Spatial

export (Vector3) var axis = Vector3.UP
export (float) var speed = 1.0

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	rotate(axis, speed * delta)
