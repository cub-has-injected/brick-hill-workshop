class_name ColorHexagon
extends Control
tool 

signal pressed()

export (Color) var color = Color.white setget set_color
export (Color) var border_color = Color("#b0b0b0") setget set_border_color
export (Color) var focus_color = Color("#00A9FE") setget set_focus_color

export (float) var border_width = 1 setget set_border_width
export (float) var focus_width = 1 setget set_focus_width

func set_color(new_color:Color)->void :
	var scope = Profiler.scope(self, "set_color", [new_color])

	if color != new_color:
		color = new_color
		update()

func set_border_color(new_border_color:Color)->void :
	var scope = Profiler.scope(self, "set_border_color", [new_border_color])

	if border_color != new_border_color:
		border_color = new_border_color
		update()

func set_focus_color(new_focus_color:Color)->void :
	var scope = Profiler.scope(self, "set_focus_color", [new_focus_color])

	if focus_color != new_focus_color:
		focus_color = new_focus_color
		update()

func set_border_width(new_border_width:float)->void :
	var scope = Profiler.scope(self, "set_border_width", [new_border_width])

	if border_width != new_border_width:
		border_width = new_border_width
		update()

func set_focus_width(new_focus_width:float)->void :
	var scope = Profiler.scope(self, "set_focus_width", [new_focus_width])

	if focus_width != new_focus_width:
		focus_width = new_focus_width
		update()

func _draw()->void :
	var scope = Profiler.scope(self, "_draw", [])

	var half_size = min(rect_size.x * 1.15, rect_size.y) * 0.5
	var center = Vector2(rect_size.x * 0.5, rect_size.y * 0.5)

	var ofs = Vector2.UP * half_size

	var vertices = PoolVector2Array()

	for i in range(0, 6):
		vertices.append(center + ofs.rotated(i * (TAU / 6)))

	if has_focus():
		draw_polygon(vertices, [focus_color], PoolVector2Array(), null, null, true)

	for i in range(0, 6):
		vertices[i] -= center
		vertices[i] -= vertices[i].normalized() * focus_width
		vertices[i] += center

	draw_polygon(vertices, [border_color], PoolVector2Array(), null, null, true)

	for i in range(0, 6):
		vertices[i] -= center
		vertices[i] -= vertices[i].normalized() * border_width
		vertices[i] += center

	draw_polygon(vertices, [color], PoolVector2Array(), null, null, true)

func _gui_input(event:InputEvent)->void :
	var scope = Profiler.scope(self, "_gui_input", [event])

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			emit_signal("pressed")
