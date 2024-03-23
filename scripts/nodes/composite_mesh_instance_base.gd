class_name CompositeMeshInstanceBase
extends Spatial
tool 

export (Material) var material:Material = null

var _mesh_instance_weakrefs: = []

func compose_meshes(mesh_global_transforms:Array, meshes:Array)->void :
	var scope = Profiler.scope(self, "compose_meshes", [mesh_global_transforms, meshes])

	assert (mesh_global_transforms.size() == meshes.size())

	for i in range(0, mesh_global_transforms.size()):
		var trx = global_transform.inverse() * mesh_global_transforms[i]
		var mesh = meshes[i]

		var mesh_instance = MeshInstance.new()
		add_child(mesh_instance)
		mesh_instance.transform = trx
		mesh_instance.mesh = mesh
		mesh_instance.material_override = material;

		_mesh_instance_weakrefs.append(weakref(mesh_instance))

func clear()->void :
	var scope = Profiler.scope(self, "clear", [])

	for mesh_instance_weakref in _mesh_instance_weakrefs:
		var mesh_instance = mesh_instance_weakref.get_ref()
		if mesh_instance:
			remove_child(mesh_instance)
			mesh_instance.queue_free()

	_mesh_instance_weakrefs.clear()
