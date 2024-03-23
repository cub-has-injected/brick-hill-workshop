extends Spatial
tool 

export (Resource) var avatar_data setget set_avatar_data
export (SpatialMaterial) var base_material:SpatialMaterial

var _head_material:SpatialMaterial
var _torso_material:SpatialMaterial
var _left_arm_material:SpatialMaterial
var _left_leg_material:SpatialMaterial
var _right_arm_material:SpatialMaterial
var _right_leg_material:SpatialMaterial

var _default_face_texture: = preload("res://resources/texture/default_face.png")

func get_node_checked(path:String)->Node:
	var scope = Profiler.scope(self, "get_node_checked", [path])

	return get_node(path) if has_node(path) else null

func get_face_viewport_container()->ViewportContainer:
	var scope = Profiler.scope(self, "get_face_viewport_container", [])

	return get_node_checked("TextureVBox/FaceViewportContainer") as ViewportContainer

func get_face_viewport()->Viewport:
	var scope = Profiler.scope(self, "get_face_viewport", [])

	return get_node_checked("TextureVBox/FaceViewportContainer/FaceViewport") as Viewport

func get_legs_viewport_container()->ViewportContainer:
	var scope = Profiler.scope(self, "get_legs_viewport_container", [])

	return get_node_checked("TextureVBox/LegsViewportContainer") as ViewportContainer

func get_legs_viewport()->Viewport:
	var scope = Profiler.scope(self, "get_legs_viewport", [])

	return get_node_checked("TextureVBox/LegsViewportContainer/LegsViewport") as Viewport

func get_head_texture_rect()->TextureRect:
	var scope = Profiler.scope(self, "get_head_texture_rect", [])

	return get_node_checked("TextureVBox/FaceViewportContainer/FaceViewport/Control/HBoxContainer/HeadTextureRect") as TextureRect

func get_face_texture_rect()->TextureRect:
	var scope = Profiler.scope(self, "get_face_texture_rect", [])

	return get_node_checked("TextureVBox/FaceViewportContainer/FaceViewport/Control/HBoxContainer/FaceTextureRect") as TextureRect

func get_face_color_rect()->ColorRect:
	var scope = Profiler.scope(self, "get_face_color_rect", [])

	return get_node_checked("TextureVBox/FaceViewportContainer/FaceViewport/Control/ColorRect") as ColorRect

func get_torso_texture_rect()->TextureRect:
	var scope = Profiler.scope(self, "get_torso_texture_rect", [])

	return get_node_checked("TextureVBox/TorsoViewportContainer/TorsoViewport/Control/TorsoTextureRect") as TextureRect

func get_torso_shirt_texture_rect()->TextureRect:
	var scope = Profiler.scope(self, "get_torso_shirt_texture_rect", [])

	return get_node_checked("TextureVBox/TorsoViewportContainer/TorsoViewport/Control/ShirtTextureRect") as TextureRect

func get_torso_t_shirt_texture_rect()->TextureRect:
	var scope = Profiler.scope(self, "get_torso_t_shirt_texture_rect", [])

	return get_node_checked("TextureVBox/TorsoViewportContainer/TorsoViewport/Control/TShirtTextureRect") as TextureRect

func get_left_arm_color_rect()->ColorRect:
	var scope = Profiler.scope(self, "get_left_arm_color_rect", [])

	return get_node_checked("TextureVBox/TorsoViewportContainer/TorsoViewport/Control/LeftArmColorRect") as ColorRect

func get_right_arm_color_rect()->ColorRect:
	var scope = Profiler.scope(self, "get_right_arm_color_rect", [])

	return get_node_checked("TextureVBox/TorsoViewportContainer/TorsoViewport/Control/RightArmColorRect") as ColorRect

func get_legs_pants_texture_rect()->TextureRect:
	var scope = Profiler.scope(self, "get_legs_pants_texture_rect", [])

	return get_node_checked("TextureVBox/LegsViewportContainer/LegsViewport/Control/PantsTextureRect") as TextureRect

func get_legs_torso_color_rect()->ColorRect:
	var scope = Profiler.scope(self, "get_legs_torso_color_rect", [])

	return get_node_checked("TextureVBox/LegsViewportContainer/LegsViewport/Control/TorsoColorRect") as ColorRect

func get_legs_left_leg_color_rect()->ColorRect:
	var scope = Profiler.scope(self, "get_legs_left_leg_color_rect", [])

	return get_node_checked("TextureVBox/LegsViewportContainer/LegsViewport/Control/LeftLegColorRect") as ColorRect

func get_legs_right_leg_color_rect()->ColorRect:
	var scope = Profiler.scope(self, "get_legs_right_leg_color_rect", [])

	return get_node_checked("TextureVBox/LegsViewportContainer/LegsViewport/Control/RightLegColorRect") as ColorRect

func get_head_mesh_instance()->MeshInstance:
	var scope = Profiler.scope(self, "get_head_mesh_instance", [])

	return get_node_checked("FigureArmature/Skeleton/FigureMesh/HeadBone/Head") as MeshInstance

func get_default_head_mesh_instance()->MeshInstance:
	var scope = Profiler.scope(self, "get_default_head_mesh_instance", [])

	return get_node_checked("FigureArmature/Skeleton/HeadMesh") as MeshInstance

func get_tool_mesh_instance()->MeshInstance:
	var scope = Profiler.scope(self, "get_tool_mesh_instance", [])

	return get_node_checked("FigureArmature/Skeleton/FigureMesh/RightArmBone/Tool") as MeshInstance


func set_avatar_data(new_avatar_data:Resource)->void :
	var scope = Profiler.scope(self, "set_avatar_data", [new_avatar_data])

	if new_avatar_data and not new_avatar_data is AvatarData:
		new_avatar_data = AvatarData.new()

	if avatar_data != new_avatar_data:
		if avatar_data:
			disconnect_avatar_data()

		avatar_data = new_avatar_data

		if avatar_data:
			connect_avatar_data()

		if is_inside_tree():
			update_avatar_data()

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	base_material = SpatialMaterial.new()

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	if not avatar_data:
		avatar_data = AvatarData.new()

func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	var face_viewport_texture: = $TextureVBox / FaceViewportContainer / FaceViewport.get_texture() as ViewportTexture
	var torso_viewport_texture: = $TextureVBox / TorsoViewportContainer / TorsoViewport.get_texture() as ViewportTexture
	var legs_viewport_texture: = $TextureVBox / LegsViewportContainer / LegsViewport.get_texture() as ViewportTexture

	face_viewport_texture.flags = Texture.FLAGS_DEFAULT
	torso_viewport_texture.flags = Texture.FLAGS_DEFAULT
	legs_viewport_texture.flags = Texture.FLAGS_DEFAULT

	_head_material = base_material.duplicate()
	_torso_material = base_material.duplicate()
	_left_arm_material = base_material.duplicate()
	_right_arm_material = base_material.duplicate()
	_left_leg_material = base_material.duplicate()
	_right_leg_material = base_material.duplicate()

	_head_material.albedo_texture = face_viewport_texture
	_torso_material.albedo_texture = torso_viewport_texture
	_left_arm_material.albedo_texture = torso_viewport_texture
	_right_arm_material.albedo_texture = torso_viewport_texture
	_left_leg_material.albedo_texture = legs_viewport_texture
	_right_leg_material.albedo_texture = legs_viewport_texture

	var default_head_mesh: = $FigureArmature / Skeleton / HeadMesh as MeshInstance
	default_head_mesh.set_surface_material(0, _head_material)

	var prop_head_mesh: = $FigureArmature / Skeleton / FigureMesh / HeadBone / Head as MeshInstance
	prop_head_mesh.material_override = _head_material

	var figure_mesh: = $FigureArmature / Skeleton / FigureMesh as MeshInstance
	figure_mesh.set_surface_material(0, _torso_material)
	figure_mesh.set_surface_material(1, _left_arm_material)
	figure_mesh.set_surface_material(2, _left_leg_material)
	figure_mesh.set_surface_material(3, _right_arm_material)
	figure_mesh.set_surface_material(4, _right_leg_material)

	update_avatar_data()

func disconnect_avatar_data()->void :
	var scope = Profiler.scope(self, "disconnect_avatar_data", [])

	if avatar_data:
		assert (avatar_data.is_connected("changed", self, "update_avatar_data"))
		avatar_data.disconnect_subresources()
		avatar_data.disconnect("changed", self, "update_avatar_data")

func connect_avatar_data()->void :
	var scope = Profiler.scope(self, "connect_avatar_data", [])

	if avatar_data:
		assert ( not avatar_data.is_connected("changed", self, "update_avatar_data"))
		avatar_data.connect_subresources()
		avatar_data.connect("changed", self, "update_avatar_data")

func update_avatar_data()->void :
	var scope = Profiler.scope(self, "update_avatar_data", [])

	if not avatar_data:
		return 

	get_face_color_rect().color = ColorUtil.srgb_to_linear(avatar_data.color_head)

	
	var head_texture_rect = get_head_texture_rect()
	head_texture_rect.texture = avatar_data.asset_head.texture.asset_png

	
	var face_texture_rect = get_face_texture_rect()
	if avatar_data.asset_face.asset_id != 0:
		face_texture_rect.texture = avatar_data.asset_face.texture.asset_png
	else :
		face_texture_rect.texture = _default_face_texture

	
	var face_viewport_container = get_face_viewport_container()
	var face_viewport = get_face_viewport()

	var face_texture_size = face_texture_rect.texture.get_size()
	var face_viewport_size:Vector2

	if avatar_data.asset_head.texture.asset_id == 0:
		face_viewport_size = face_texture_size
		head_texture_rect.visible = false
	else :
		var head_texture_size = head_texture_rect.texture.get_size()
		face_viewport_size = Vector2(max(face_texture_size.x, head_texture_size.x) * 2.0, max(face_texture_size.y, head_texture_size.y))
		head_texture_rect.visible = true

	face_viewport.size = face_viewport_size
	face_viewport_container.rect_size = face_viewport_size

	
	get_legs_torso_color_rect().color = ColorUtil.srgb_to_linear(avatar_data.color_torso)
	get_legs_left_leg_color_rect().color = ColorUtil.srgb_to_linear(avatar_data.color_left_leg)
	get_legs_right_leg_color_rect().color = ColorUtil.srgb_to_linear(avatar_data.color_right_leg)

	
	var pants_texture_rect = get_legs_pants_texture_rect()
	pants_texture_rect.texture = avatar_data.asset_pants.texture.asset_png

	var legs_viewport_container = get_legs_viewport_container()
	var legs_viewport = get_legs_viewport()
	var pants_texture_size = pants_texture_rect.texture.get_size()
	pants_texture_size = Vector2(max(pants_texture_size.x, 2), max(pants_texture_size.y, 2))
	legs_viewport.size = pants_texture_size
	legs_viewport_container.rect_size = pants_texture_size

	
	get_left_arm_color_rect().color = ColorUtil.srgb_to_linear(avatar_data.color_left_arm)
	get_right_arm_color_rect().color = ColorUtil.srgb_to_linear(avatar_data.color_right_arm)

	
	get_torso_shirt_texture_rect().texture = avatar_data.asset_shirt.texture.asset_png
	get_torso_t_shirt_texture_rect().texture = avatar_data.asset_t_shirt.texture.asset_png

	
	get_head_mesh_instance().mesh = avatar_data.asset_head.mesh.asset_obj
	get_default_head_mesh_instance().visible = avatar_data.asset_head.asset_id == 0

	
	var tool_mesh_instance = get_tool_mesh_instance()
	tool_mesh_instance.mesh = avatar_data.asset_tool.mesh.asset_obj

	
	if tool_mesh_instance.mesh:
		var tool_material = SpatialMaterial.new()
		tool_material.albedo_texture = avatar_data.asset_tool.texture.asset_png
		tool_material.roughness = 0.75
		tool_mesh_instance.material_override = tool_material
	else :
		tool_mesh_instance.material_override = null

	
	for i in range(0, 5):
		var hat_mesh_instance = get_node("FigureArmature/Skeleton/FigureMesh/HeadBone/Hat%s" % [i + 1])
		hat_mesh_instance.mesh = avatar_data.assets_hats[i].mesh.asset_obj
		if is_instance_valid(hat_mesh_instance.mesh):
			var hat_material = SpatialMaterial.new()
			hat_material.albedo_texture = avatar_data.assets_hats[i].texture.asset_png
			hat_material.roughness = 0.75
			hat_mesh_instance.material_override = hat_material
		else :
			hat_mesh_instance.material_override = null

	
	var torso_texture_rect = get_torso_texture_rect()
	if pants_texture_size == Vector2(2, 2):
		torso_texture_rect.texture.flags &= ~ Texture.FLAG_FILTER
	else :
		torso_texture_rect.texture.flags |= Texture.FLAG_FILTER


func set_look_direction(normal:Vector3)->void :
	var scope = Profiler.scope(self, "set_look_direction", [normal])

	return 
	

func get_look_direction()->Vector3:
	var scope = Profiler.scope(self, "get_look_direction", [])

	return Vector3.FORWARD
	

func set_animation(index:int)->void :
	var scope = Profiler.scope(self, "set_animation", [index])

	$FallingTimer.stop()
	$AnimationTree.set("parameters/Legs/current", index)
	$AnimationTree.set("parameters/Torso/current", index)

func set_idle()->void :
	var scope = Profiler.scope(self, "set_idle", [])

	set_animation(0)

func set_walking(speed:float = 1.0)->void :
	var scope = Profiler.scope(self, "set_walking", [speed])

	$AnimationTree.set("parameters/LegsWalkSpeed/scale", speed)
	$AnimationTree.set("parameters/TorsoWalkSpeed/scale", speed)

	if $AnimationTree.get("parameters/Legs/current") == 1 and $AnimationTree.get("parameters/Torso/current") == 1:
		return 

	$AnimationTree.set("parameters/LegsWalkSeek/seek_position", 0.0)
	$AnimationTree.set("parameters/TorsoWalkSeek/seek_position", 0.0)

	set_animation(1)

func set_jumping()->void :
	var scope = Profiler.scope(self, "set_jumping", [])

	set_animation(2)

func set_falling()->void :
	var scope = Profiler.scope(self, "set_falling", [])

	set_animation(2)
	$FallingTimer.start()

func set_landing()->void :
	var scope = Profiler.scope(self, "set_landing", [])

	var landing_delay = 0.2

	$AnimationTree.set("parameters/Torso/current", 4)
	yield (get_tree().create_timer(landing_delay), "timeout")
	$AnimationTree.set("parameters/LegsWalkSeek/seek_position", landing_delay + 0.1)
	$AnimationTree.set("parameters/TorsoWalkSeek/seek_position", landing_delay + 0.1)
	$AnimationTree.set("parameters/Torso/current", $AnimationTree.get("parameters/Legs/current"))
