class_name Orbiter
extends Spatial
tool 

export (Vector3) var sine_axis = Vector3.FORWARD
export (Vector3) var cosine_axis = Vector3.RIGHT
export (float) var sine_magnitude = 5.0
export (float) var cosine_magnitude = 5.0
export (float) var speed = 1.0

var time: = 0.0

func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	update_position()

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	if not Engine.is_editor_hint():
		time = fmod(time + delta * speed, TAU)
		update_position()

func update_position()->void :
	var scope = Profiler.scope(self, "update_position", [])

	translation = sin(time) * sine_axis * sine_magnitude + cos(time) * cosine_axis * cosine_magnitude
