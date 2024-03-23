extends Area

func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	connect("body_entered", self, "body_entered")

func body_entered(body:Node)->void :
	var scope = Profiler.scope(self, "body_entered", [body])

	if body is RigidBody and body.sleeping:
		body.sleeping = false
