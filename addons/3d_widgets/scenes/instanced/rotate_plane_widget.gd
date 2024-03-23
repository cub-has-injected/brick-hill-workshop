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
	var radius = 0.25

	var ring_x = $AxisX / CollisionShape
	ring_x.transform.basis = ring_x.transform.basis.orthonormalized().scaled(Vector3.ONE * 0.5 * radius)

	var ring_y = $AxisY / CollisionShape
	ring_y.transform.basis = ring_y.transform.basis.orthonormalized().scaled(Vector3.ONE * 0.5 * radius)

	var ring_z = $AxisZ / CollisionShape
	ring_z.transform.basis = ring_z.transform.basis.orthonormalized().scaled(Vector3.ONE * 0.5 * radius)
