class_name ToolBar
extends PanelContainer

signal menu()

signal save()

signal cut()
signal copy()
signal paste()

signal undo()
signal redo()

signal set_collision(collision)
signal set_grid(grid)
signal set_box_select(box_select)

signal group()
signal glue()

signal tool_move_drag()
signal tool_move_axis()
signal tool_move_plane()
signal tool_rotate_plane()
signal tool_resize_face()
signal tool_resize_edge()
signal tool_resize_corner()
signal tool_paint_color()
signal tool_paint_surface()
signal tool_paint_material()
signal tool_lock()
signal tool_anchor()

signal set_picker_color(color)
signal set_picker_connection(target, method)
signal show_color_picker(control, parent, picker_origin, control_origin)
signal hide_color_picker()

signal show_surface_picker()
signal hide_surface_picker()
signal show_material_picker()
signal hide_material_picker()


func menu()->void :
	var scope = Profiler.scope(self, "menu", [])

	emit_signal("menu")

func save()->void :
	var scope = Profiler.scope(self, "save", [])

	emit_signal("save")

func cut()->void :
	var scope = Profiler.scope(self, "cut", [])

	emit_signal("cut")

func copy()->void :
	var scope = Profiler.scope(self, "copy", [])

	emit_signal("copy")

func paste()->void :
	var scope = Profiler.scope(self, "paste", [])

	emit_signal("paste")


func undo()->void :
	var scope = Profiler.scope(self, "undo", [])

	emit_signal("undo")

func redo()->void :
	var scope = Profiler.scope(self, "redo", [])

	emit_signal("redo")

func set_collision(new_collision:bool)->void :
	var scope = Profiler.scope(self, "set_collision", [new_collision])

	emit_signal("set_collision", new_collision)

func get_collision()->bool:
	var scope = Profiler.scope(self, "get_collision", [])

	return $HBoxContainer / ScrollContainer / Buttons / Collision.pressed

func set_grid(new_grid:bool)->void :
	var scope = Profiler.scope(self, "set_grid", [new_grid])

	emit_signal("set_grid", new_grid)

func get_grid()->bool:
	var scope = Profiler.scope(self, "get_grid", [])

	return $HBoxContainer / ScrollContainer / Buttons / Grid.pressed

func set_box_select(new_box_select:bool)->void :
	var scope = Profiler.scope(self, "set_box_select", [new_box_select])

	emit_signal("set_box_select", new_box_select)

func get_box_select()->bool:
	var scope = Profiler.scope(self, "get_box_select", [])

	return $HBoxContainer / ScrollContainer / Buttons / BoxSelect.pressed

func group()->void :
	var scope = Profiler.scope(self, "group", [])

	emit_signal("group")

func glue()->void :
	var scope = Profiler.scope(self, "glue", [])

	emit_signal("glue")

func tool_move_drag()->void :
	var scope = Profiler.scope(self, "tool_move_drag", [])

	emit_signal("tool_move_drag")

func tool_move_axis()->void :
	var scope = Profiler.scope(self, "tool_move_axis", [])

	emit_signal("tool_move_axis")

func tool_move_plane()->void :
	var scope = Profiler.scope(self, "tool_move_plane", [])

	emit_signal("tool_move_plane")

func tool_rotate_plane()->void :
	var scope = Profiler.scope(self, "tool_rotate_plane", [])

	emit_signal("tool_rotate_plane")

func tool_resize_face()->void :
	var scope = Profiler.scope(self, "tool_resize_face", [])

	emit_signal("tool_resize_face")

func tool_resize_edge()->void :
	var scope = Profiler.scope(self, "tool_resize_edge", [])

	emit_signal("tool_resize_edge")

func tool_resize_corner()->void :
	var scope = Profiler.scope(self, "tool_resize_corner", [])

	emit_signal("tool_resize_corner")

func tool_paint_color()->void :
	var scope = Profiler.scope(self, "tool_paint_color", [])

	emit_signal("tool_paint_color")

func tool_paint_surface()->void :
	var scope = Profiler.scope(self, "tool_paint_surface", [])

	emit_signal("tool_paint_surface")

func tool_paint_material()->void :
	var scope = Profiler.scope(self, "tool_paint_material", [])

	emit_signal("tool_paint_material")

func tool_lock()->void :
	var scope = Profiler.scope(self, "tool_lock", [])

	emit_signal("tool_lock")

func tool_anchor()->void :
	var scope = Profiler.scope(self, "tool_anchor", [])

	emit_signal("tool_anchor")

func color_picker_toggled(state:bool)->void :
	var scope = Profiler.scope(self, "color_picker_toggled", [state])

	if state:
		$HBoxContainer / ScrollContainer / Buttons / ToolButtons / ColorHBox / ColorTool.pressed = true
		$HBoxContainer / ScrollContainer / Buttons / ToolButtons.tool_paint_color()
		var color_picker_button = $HBoxContainer / ScrollContainer / Buttons / ToolButtons / ColorHBox / ColorPicker
		emit_signal("set_picker_color", WorkshopDirectory.paint_color_manager().active_color)
		emit_signal("set_picker_connection", WorkshopDirectory.paint_color_manager(), "set_active_color")
		emit_signal("show_color_picker", color_picker_button, get_parent(), CORNER_TOP_RIGHT, CORNER_BOTTOM_RIGHT)
	else :
		emit_signal("hide_color_picker")

func show_surface_picker(new_show:bool)->void :
	var scope = Profiler.scope(self, "show_surface_picker", [new_show])

	$HBoxContainer / ScrollContainer / Buttons / ToolButtons.tool_paint_surface()
	if new_show:
		emit_signal("show_surface_picker")
	else :
		emit_signal("hide_surface_picker")

func show_material_picker(new_show:bool)->void :
	var scope = Profiler.scope(self, "show_material_picker", [new_show])

	$HBoxContainer / ScrollContainer / Buttons / ToolButtons.tool_paint_material()
	if new_show:
		emit_signal("show_material_picker")
	else :
		emit_signal("hide_material_picker")


func set_color_picker_pressed(new_pressed:bool)->void :
	var scope = Profiler.scope(self, "set_color_picker_pressed", [new_pressed])

	$HBoxContainer / ScrollContainer / Buttons / ToolButtons / ColorHBox / ColorPicker.pressed = new_pressed

func set_material_picker_pressed(new_pressed:bool)->void :
	var scope = Profiler.scope(self, "set_material_picker_pressed", [new_pressed])

	$HBoxContainer / ScrollContainer / Buttons / ToolButtons / MaterialHBox / MaterialPicker.pressed = new_pressed

func set_surface_picker_pressed(new_pressed:bool)->void :
	var scope = Profiler.scope(self, "set_surface_picker_pressed", [new_pressed])

	$HBoxContainer / ScrollContainer / Buttons / ToolButtons / SurfaceHBox / SurfacePicker.pressed = new_pressed

func set_active_color(new_active_color:Color)->void :
	var scope = Profiler.scope(self, "set_active_color", [new_active_color])

	$HBoxContainer / ScrollContainer / Buttons / ToolButtons / ColorHBox / ColorPicker.set_active_color(new_active_color)

func set_active_surface(new_active_surface:int)->void :
	var scope = Profiler.scope(self, "set_active_surface", [new_active_surface])

	$HBoxContainer / ScrollContainer / Buttons / ToolButtons / SurfaceHBox / SurfacePicker / Border / ActiveSurface.populate_active_surface(new_active_surface)

func set_active_material(new_active_material:int)->void :
	var scope = Profiler.scope(self, "set_active_material", [new_active_material])

	$HBoxContainer / ScrollContainer / Buttons / ToolButtons / MaterialHBox / MaterialPicker / Border / ActiveMaterial.populate_active_material(new_active_material)

func set_collision_pressed(new_pressed:bool)->void :
	var scope = Profiler.scope(self, "set_collision_pressed", [new_pressed])

	$HBoxContainer / ScrollContainer / Buttons / Collision.pressed = new_pressed

func set_grid_pressed(new_pressed:bool)->void :
	var scope = Profiler.scope(self, "set_grid_pressed", [new_pressed])

	$HBoxContainer / ScrollContainer / Buttons / Grid.pressed = new_pressed

func set_disabled(new_disabled:bool)->void :
	var scope = Profiler.scope(self, "set_disabled", [new_disabled])

	var controls: = [
		$HBoxContainer / MenuWrapper / MenuButton, 
		$HBoxContainer / ScrollContainer / Buttons / Save, 
		$HBoxContainer / ScrollContainer / Buttons / Paste, 
		$HBoxContainer / ScrollContainer / Buttons / Copy, 
		$HBoxContainer / ScrollContainer / Buttons / Cut, 
		$HBoxContainer / ScrollContainer / Buttons / Undo, 
		$HBoxContainer / ScrollContainer / Buttons / Redo, 
		$HBoxContainer / ScrollContainer / Buttons / Collision, 
		$HBoxContainer / ScrollContainer / Buttons / Grid, 
		$HBoxContainer / ScrollContainer / Buttons / BoxSelect, 
		$HBoxContainer / ScrollContainer / Buttons / Group, 
		$HBoxContainer / ScrollContainer / Buttons / Glue, 
		$HBoxContainer / ScrollContainer / Buttons / ToolButtons / MoveDrag, 
		$HBoxContainer / ScrollContainer / Buttons / ToolButtons / MoveAxis, 
		$HBoxContainer / ScrollContainer / Buttons / ToolButtons / MovePlane, 
		$HBoxContainer / ScrollContainer / Buttons / ToolButtons / RotatePlane, 
		$HBoxContainer / ScrollContainer / Buttons / ToolButtons / ResizeFace, 
		$HBoxContainer / ScrollContainer / Buttons / ToolButtons / ResizeEdge, 
		$HBoxContainer / ScrollContainer / Buttons / ToolButtons / ResizeCorner, 
		$HBoxContainer / ScrollContainer / Buttons / ToolButtons / ColorHBox / ColorTool, 
		$HBoxContainer / ScrollContainer / Buttons / ToolButtons / ColorHBox / ColorPicker, 
		$HBoxContainer / ScrollContainer / Buttons / ToolButtons / SurfaceHBox / SurfaceTool, 
		$HBoxContainer / ScrollContainer / Buttons / ToolButtons / SurfaceHBox / SurfacePicker, 
		$HBoxContainer / ScrollContainer / Buttons / ToolButtons / MaterialHBox / MaterialTool, 
		$HBoxContainer / ScrollContainer / Buttons / ToolButtons / MaterialHBox / MaterialPicker, 
		$HBoxContainer / ScrollContainer / Buttons / ToolButtons / NodeButtons / Lock, 
		$HBoxContainer / ScrollContainer / Buttons / ToolButtons / NodeButtons / Anchor
	]

	for control in controls:
		control.disabled = new_disabled
