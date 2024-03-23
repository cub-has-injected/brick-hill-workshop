extends MeshInstance
tool 

export (bool) var update setget set_update

func set_update(new_update:bool)->void :
	if update != new_update:
		set_mesh(CubeMesh.new())

func _init()->void :
	set_mesh(CubeMesh.new())
