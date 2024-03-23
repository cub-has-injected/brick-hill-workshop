class_name BrickHillCamera
extends Camera

func update_draw_distance()->void :
	var scope = Profiler.scope(self, "update_draw_distance", [])

	far = GraphicsSettings.data.draw_distance

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	GraphicsSettings.data.connect("draw_distance_changed", self, "update_draw_distance")

	update_draw_distance()
