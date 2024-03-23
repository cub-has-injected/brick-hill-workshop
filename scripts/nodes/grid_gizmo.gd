class_name WorldGrid
extends ImmediateGeometry
tool 

signal visibility_changed_bool(visibility)

export (Vector2) var extents = Vector2(100, 100) setget set_extents
export (Vector2) var highlight = Vector2(4, 4) setget set_highlight
export (Color) var normal_color: = Color(0.5, 0.5, 0.5) setget set_normal_color
export (Color) var highlight_color: = Color(0.8, 0.8, 0.8) setget set_highlight_color

func set_extents(new_extents:Vector2)->void :
	var scope = Profiler.scope(self, "set_extents", [new_extents])

	if extents != new_extents:
		extents = new_extents
		update_geometry()

func set_highlight(new_highlight:Vector2)->void :
	var scope = Profiler.scope(self, "set_highlight", [new_highlight])

	if highlight != new_highlight:
		highlight = new_highlight
		update_geometry()

func set_normal_color(new_normal_color:Color)->void :
	var scope = Profiler.scope(self, "set_normal_color", [new_normal_color])

	if normal_color != new_normal_color:
		normal_color = new_normal_color
		update_geometry()

func set_highlight_color(new_highlight_color:Color)->void :
	var scope = Profiler.scope(self, "set_highlight_color", [new_highlight_color])

	if highlight_color != new_highlight_color:
		highlight_color = new_highlight_color
		update_geometry()

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	connect("visibility_changed", self, "visibility_changed")

func visibility_changed()->void :
	var scope = Profiler.scope(self, "visibility_changed", [])

	emit_signal("visibility_changed_bool", visible)

func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	update_geometry()

func update_geometry():
	var scope = Profiler.scope(self, "update_geometry", [])

	clear()
	begin(Mesh.PRIMITIVE_LINES)
	for x in range( - extents.x, extents.x + 1):
		set_color(normal_color if not x % int(highlight.x) == 0 else highlight_color)
		add_vertex(Vector3(x, 0, extents.y))
		add_vertex(Vector3(x, 0, - extents.y))

	for y in range( - extents.y, extents.y + 1):
		set_color(normal_color if not y % int(highlight.y) == 0 else highlight_color)
		add_vertex(Vector3(extents.x, 0, y))
		add_vertex(Vector3( - extents.x, 0, y))
	end()
