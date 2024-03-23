class_name HexagonGrid
extends VBoxContainer
tool 

signal color_selected(color)

export (Vector2) var cell_size: = Vector2(28, 32) setget set_cell_size
export (Array, Array, Color) var cells setget set_cells

var _hbox_containers: = []
var _color_hexagons: = []

func set_cell_size(new_cell_size:Vector2)->void :
	var scope = Profiler.scope(self, "set_cell_size", [new_cell_size])

	if cell_size != new_cell_size:
		cell_size = new_cell_size
		rebuild()

func set_cells(new_cells:Array)->void :
	var scope = Profiler.scope(self, "set_cells", [new_cells])

	if cells != new_cells:
		cells = new_cells
		rebuild()

func rebuild()->void :
	var scope = Profiler.scope(self, "rebuild", [])

	_hbox_containers.clear()
	_color_hexagons.clear()

	for child in get_children():
		if child.has_meta("hexagon_grid_child"):
			remove_child(child)
			child.queue_free()

	for row in cells:
		var hbox = HBoxContainer.new()
		hbox.set_meta("hexagon_grid_child", true)
		hbox.size_flags_horizontal = SIZE_SHRINK_CENTER
		hbox.set("custom_constants/separation", 0)

		for cell in row:
			var color_hex = ColorHexagon.new()
			color_hex.rect_size = cell_size
			color_hex.rect_min_size = cell_size
			color_hex.color = cell
			color_hex.border_width = 1.5
			color_hex.focus_width = 2
			color_hex.focus_mode = Control.FOCUS_ALL
			color_hex.connect("pressed", self, "color_selected", [cell])
			hbox.add_child(color_hex)
			_color_hexagons.append(color_hex)

		add_child(hbox)
		_hbox_containers.append(hbox)

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	set("custom_constants/separation", - 10)

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	rebuild()

func color_selected(color:Color)->void :
	var scope = Profiler.scope(self, "color_selected", [color])

	emit_signal("color_selected", color)
