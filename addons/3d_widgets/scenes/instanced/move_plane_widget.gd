extends Spatial
tool 

export (Vector3) var size: = Vector3.ONE * 2 setget set_size

func set_size(new_size:Vector3)->void :
	if size != new_size:
		size = new_size
		if is_inside_tree():
			update()

func _enter_tree()->void :
	update()

func update()->void :
	var local_size = size + Vector3.ONE * 2.0

	$AxisX / CollisionShape.shape.extents = Vector3(local_size.y, 0.05, local_size.z) * 0.5
	$AxisY / CollisionShape.shape.extents = Vector3(local_size.x, 0.05, local_size.z) * 0.5
	$AxisZ / CollisionShape.shape.extents = Vector3(local_size.y, 0.05, local_size.x) * 0.5

	$AxisX / CollisionShape / TopMesh.mesh.size.z = local_size.z + 0.05
	$AxisX / CollisionShape / TopMesh.transform.origin = Vector3(local_size.y * 0.5, 0, 0)
	$AxisX / CollisionShape / BottomMesh.mesh.size.z = local_size.z + 0.05
	$AxisX / CollisionShape / BottomMesh.transform.origin = Vector3( - local_size.y * 0.5, 0, 0)
	$AxisX / CollisionShape / LeftMesh.mesh.size.x = local_size.y + 0.05
	$AxisX / CollisionShape / LeftMesh.transform.origin = Vector3(0, 0, - local_size.z * 0.5)
	$AxisX / CollisionShape / RightMesh.mesh.size.x = local_size.y + 0.05
	$AxisX / CollisionShape / RightMesh.transform.origin = Vector3(0, 0, local_size.z * 0.5)

	$AxisY / CollisionShape / TopMesh.mesh.size.z = local_size.z + 0.05
	$AxisY / CollisionShape / TopMesh.transform.origin = Vector3(local_size.x * 0.5, 0, 0)
	$AxisY / CollisionShape / BottomMesh.mesh.size.z = local_size.z + 0.05
	$AxisY / CollisionShape / BottomMesh.transform.origin = Vector3( - local_size.x * 0.5, 0, 0)
	$AxisY / CollisionShape / LeftMesh.mesh.size.x = local_size.x + 0.05
	$AxisY / CollisionShape / LeftMesh.transform.origin = Vector3(0, 0, - local_size.z * 0.5)
	$AxisY / CollisionShape / RightMesh.mesh.size.x = local_size.x + 0.05
	$AxisY / CollisionShape / RightMesh.transform.origin = Vector3(0, 0, local_size.z * 0.5)

	$AxisZ / CollisionShape / TopMesh.mesh.size.x = local_size.x + 0.05
	$AxisZ / CollisionShape / TopMesh.transform.origin = Vector3(local_size.y * 0.5, 0, 0)
	$AxisZ / CollisionShape / BottomMesh.mesh.size.x = local_size.x + 0.05
	$AxisZ / CollisionShape / BottomMesh.transform.origin = Vector3( - local_size.y * 0.5, 0, 0)
	$AxisZ / CollisionShape / LeftMesh.mesh.size.z = local_size.y + 0.05
	$AxisZ / CollisionShape / LeftMesh.transform.origin = Vector3(0, 0, - local_size.x * 0.5)
	$AxisZ / CollisionShape / RightMesh.mesh.size.z = local_size.y + 0.05
	$AxisZ / CollisionShape / RightMesh.transform.origin = Vector3(0, 0, local_size.x * 0.5)
