"\nCollision object representing the far plane of its viewport's active camera\n"

class_name FarPlane
extends RigidBody

func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	get_viewport().connect("size_changed", self, "update_size")
	update_size()

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	var viewport = get_viewport()
	assert (viewport != null, "Can't update FarPlane without a viewport")

	var camera = viewport.get_camera()
	assert (camera != null, "Can't update FarPlane without a camera")

	global_transform.origin = camera.global_transform.origin + camera.far * - camera.global_transform.basis.z
	global_transform.basis = camera.global_transform.basis

func update_size()->void :
	var scope = Profiler.scope(self, "update_size", [])

	var viewport = get_viewport()
	assert (viewport != null, "Can't update FarPlane without a viewport")

	var camera = viewport.get_camera()
	assert (camera != null, "Can't update FarPlane without a camera")

	var min_ray = camera.project_local_ray_normal(Vector2.ZERO)

	var size = Plane(Vector3.BACK, - camera.far).intersects_ray(Vector3.ZERO, min_ray).abs()
	$CollisionShape.shape.extents = Vector3(size.x, size.y, 0.01)
