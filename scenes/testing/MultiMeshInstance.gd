extends MultiMeshInstance
tool 

func _process(delta:float)->void :
	multimesh.set_instance_transform(0, $Spatial.global_transform)
