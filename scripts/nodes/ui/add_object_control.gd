class_name AddObjectControl
extends HBoxContainer
tool 

var option_button:OptionButton = null
var border:ColorRect = null
var add_object_button:Button = null

var items: = [
	{
		"name":"Brick", 
		"icon":BrickHillResources.ICONS.tree_cube, 
		"class":BrickHillBrickObject, 
		"shape":ModelManager.BrickMeshType.CUBE
	}, 
	{
		"name":"Round", 
		"icon":BrickHillResources.ICONS.tree_round, 
		"class":BrickHillBrickObject, 
		"shape":ModelManager.BrickMeshType.CYLINDER
	}, 
	{
		"name":"Half Round", 
		"icon":BrickHillResources.ICONS.tree_round, 
		"class":BrickHillBrickObject, 
		"shape":ModelManager.BrickMeshType.CYLINDER_HALF
	}, 
	{
		"name":"Quarter Round", 
		"icon":BrickHillResources.ICONS.tree_round, 
		"class":BrickHillBrickObject, 
		"shape":ModelManager.BrickMeshType.CYLINDER_QUARTER
	}, 
	{
		"name":"Inverse Half Round", 
		"icon":BrickHillResources.ICONS.tree_special, 
		"class":BrickHillBrickObject, 
		"shape":ModelManager.BrickMeshType.INVERSE_CYLINDER_HALF
	}, 
	{
		"name":"Inverse Quarter Round", 
		"icon":BrickHillResources.ICONS.tree_special, 
		"class":BrickHillBrickObject, 
		"shape":ModelManager.BrickMeshType.INVERSE_CYLINDER_QUARTER
	}, 
	{
		"name":"Wedge", 
		"icon":BrickHillResources.ICONS.tree_wedge, 
		"class":BrickHillBrickObject, 
		"shape":ModelManager.BrickMeshType.WEDGE
	}, 
	{
		"name":"Wedge Corner", 
		"icon":BrickHillResources.ICONS.tree_wedge, 
		"class":BrickHillBrickObject, 
		"shape":ModelManager.BrickMeshType.WEDGE_CORNER
	}, 
	{
		"name":"Wedge Edge", 
		"icon":BrickHillResources.ICONS.tree_wedge, 
		"class":BrickHillBrickObject, 
		"shape":ModelManager.BrickMeshType.WEDGE_EDGE
	}, 
	{
		"name":"Sphere", 
		"icon":BrickHillResources.ICONS.tree_special, 
		"class":BrickHillBrickObject, 
		"shape":ModelManager.BrickMeshType.SPHERE
	}, 
	{
		"name":"Sphere Half", 
		"icon":BrickHillResources.ICONS.tree_special, 
		"class":BrickHillBrickObject, 
		"shape":ModelManager.BrickMeshType.SPHERE_HALF
	}, 
	{
		"name":"Sphere Quarter", 
		"icon":BrickHillResources.ICONS.tree_special, 
		"class":BrickHillBrickObject, 
		"shape":ModelManager.BrickMeshType.SPHERE_QUARTER
	}, 
	{
		"name":"Sphere Eigth", 
		"icon":BrickHillResources.ICONS.tree_special, 
		"class":BrickHillBrickObject, 
		"shape":ModelManager.BrickMeshType.SPHERE_EIGTH
	}, 
	{
		"name":"Group", 
		"icon":BrickHillResources.ICONS.tree_group, 
		"class":BrickHillGroup
	}, 
	{
		"name":"Glue", 
		"icon":BrickHillResources.ICONS.tree_glue, 
		"class":BrickHillGlue
	}, 
	{
		"name":"Spawn Point", 
		"icon":BrickHillResources.ICONS.tree_special, 
		"class":BrickHillSpawnPoint
	}, 
	{
		"name":"Sticker", 
		"icon":BrickHillResources.ICONS.tree_sticker, 
		"class":BrickHillSticker
	}, 
	{
		"name":"Script", 
		"icon":BrickHillResources.ICONS.tree_script, 
	}, 
] setget set_items

func set_items(new_items:Array)->void :
	var scope = Profiler.scope(self, "set_items", [new_items])

	if items != new_items:
		items = new_items

		update_items()

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	for child in get_children():
		if child != option_button and child != border and child.has_meta("add_object_child"):
			remove_child(child)
			child.queue_free()

	option_button = OptionButton.new()
	option_button.size_flags_horizontal = SIZE_EXPAND_FILL

	add_object_button = Button.new()
	add_object_button.text = "+"
	add_object_button.set_anchors_and_margins_preset(PRESET_WIDE)
	add_object_button.margin_top = 1
	add_object_button.margin_left = 1
	add_object_button.margin_right = - 1
	add_object_button.margin_bottom = - 1
	add_object_button.connect("pressed", self, "add_object")

	border = ColorRect.new()
	border.color = Color.black
	border.rect_min_size = Vector2(28, 28)
	border.add_child(add_object_button)

	option_button.set_meta("add_object_child", true)
	border.set_meta("add_object_child", true)

	add_child(option_button)
	add_child(border)

	update_items()

func set_disabled(new_disabled:bool)->void :
	var scope = Profiler.scope(self, "set_disabled", [new_disabled])

	add_object_button.set_disabled(new_disabled)

func update_items():
	var scope = Profiler.scope(self, "update_items", [])

	option_button.clear()
	for i in range(0, items.size()):
		var item = items[i]
		option_button.add_icon_item(item["icon"], item["name"], i)

func add_object()->void :
	var scope = Profiler.scope(self, "add_object", [])

	var set_root = WorkshopDirectory.set_root()
	assert (set_root)

	var id = option_button.get_item_id(option_button.selected)
	var item = items[id]

	if not "class" in item:
		return 

	var new_node = item["class"].new()
	new_node.name = item["name"]
	new_node.size = Vector3(4, 4, 4)

	if "anchored" in new_node:
		new_node.anchored = true

	if new_node is BrickHillBrickObject:
		new_node.shape = item["shape"]

		new_node.colors = PoolColorArray([
			Color.red, 
			Color.red, 
			Color.red, 
			Color.red, 
			Color.red, 
			Color.red, 
		])
		new_node.surfaces = PoolByteArray([
			BrickHillBrickObject.SurfaceType.STUDDED, 
			BrickHillBrickObject.SurfaceType.INLETS, 
			BrickHillBrickObject.SurfaceType.SMOOTH, 
			BrickHillBrickObject.SurfaceType.SMOOTH, 
			BrickHillBrickObject.SurfaceType.SMOOTH, 
			BrickHillBrickObject.SurfaceType.SMOOTH
		])
		new_node.uv_offset = Vector2(randf() * 512, randf() * 512)
	elif new_node is BrickHillSpawnPoint:
		new_node.size = Vector3(4, 6, 1)

	var workshop_camera = WorkshopDirectory.workshop_camera()
	new_node.transform.origin = workshop_camera.global_transform.origin - workshop_camera.global_transform.basis.z * workshop_camera.zoom

	var snap_settings = WorkshopDirectory.snap_settings()
	if snap_settings.snap_move:
		new_node.transform.origin = (new_node.transform.origin / snap_settings.snap_move_step).round() * snap_settings.snap_move_step

	CreateNodeAction.new(new_node, set_root).execute()

func shape_next()->void :
	var scope = Profiler.scope(self, "shape_next", [])

	option_button.selected = (option_button.selected + 1) % option_button.get_item_count()

func shape_prev()->void :
	var scope = Profiler.scope(self, "shape_prev", [])

	option_button.selected = abs(posmod(option_button.selected - 1, option_button.get_item_count()))
