class_name ModelCollisionShape
extends CollisionShape
tool 

export (String) var model_name: = "" setget set_model_name

func set_model_name(new_model_name:String)->void :
	var scope = Profiler.scope(self, "set_model_name", [new_model_name])

	if model_name != new_model_name:
		model_name = new_model_name
		if is_inside_tree():
			model_name_changed()

func model_name_changed()->void :
	var scope = Profiler.scope(self, "model_name_changed", [])

	update_mesh()

func update_mesh()->void :
	var scope = Profiler.scope(self, "update_mesh", [])

	set_shape(ModelManager.get_model_shape(model_name))

func _enter_tree():
	var scope = Profiler.scope(self, "_enter_tree", [])

	model_name_changed()
