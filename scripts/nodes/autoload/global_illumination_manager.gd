extends GIProbe
tool 

signal baked_changed()

func bake_gi()->void :
	var scope = Profiler.scope(self, "bake_gi", [])

	bake(null, false)
	emit_signal("baked_changed")

func bake_debug_gi()->void :
	var scope = Profiler.scope(self, "bake_debug_gi", [])

	bake(null, true)
	emit_signal("baked_changed")

func clear_gi()->void :
	var scope = Profiler.scope(self, "clear_gi", [])

	data = null
	emit_signal("baked_changed")

func is_baked()->bool:
	var scope = Profiler.scope(self, "is_baked", [])

	return data != null
