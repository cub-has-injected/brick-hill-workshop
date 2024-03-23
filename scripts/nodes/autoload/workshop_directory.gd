extends Node
tool 

func get_workshop_node(path:NodePath = NodePath("."))->Node:
	var scope = Profiler.scope(self, "get_workshop_node", [path])

	var scene:WorkshopRoot
	scene = get_node_or_null("/root/Launch/SceneLoader/WorkshopRoot")

	if not scene:
		scene = get_tree().get_current_scene() as WorkshopRoot

	if not scene:
		scene = get_tree().get_edited_scene_root() as WorkshopRoot

	if not scene:
		assert (false, "No WorkshopRoot available")

	var node = scene.get_node_or_null(path)
	assert (node != null, "Node at path %s does not exist" % [path])
	return node


func workshop_root()->WorkshopRoot:
	var scope = Profiler.scope(self, "workshop_root", [])

	return get_workshop_node() as WorkshopRoot

func tool_mode()->ToolMode:
	var scope = Profiler.scope(self, "tool_mode", [])

	return get_workshop_node("ViewportSizer/MainViewport/ObjectMovement/ToolMode") as ToolMode

func snap_settings()->SnapSettings:
	var scope = Profiler.scope(self, "snap_settings", [])

	return get_workshop_node("ViewportSizer/MainViewport/ObjectMovement/SnapSettings") as SnapSettings

func collision_settings()->CollisionSettings:
	var scope = Profiler.scope(self, "collision_settings", [])

	return get_workshop_node("ViewportSizer/MainViewport/ObjectMovement/CollisionSettings") as CollisionSettings

func widgets()->Widgets:
	var scope = Profiler.scope(self, "widgets", [])

	return get_workshop_node("ViewportSizer/MainViewport/Root/Widgets") as Widgets

func origin_dot()->MeshInstance:
	var scope = Profiler.scope(self, "origin_dot", [])

	return get_workshop_node("ViewportSizer/MainViewport/Root/OriginDot") as MeshInstance

func widgets_remote_transform()->WidgetsRemoteTransform:
	var scope = Profiler.scope(self, "widgets_remote_transform", [])

	return get_workshop_node("ViewportSizer/MainViewport/Root/WidgetsRemoteTransform") as WidgetsRemoteTransform

func composite_object()->CompositeObject:
	var scope = Profiler.scope(self, "composite_object", [])

	return get_workshop_node("ViewportSizer/MainViewport/Root/CompositeObject") as CompositeObject

func movement_proxy()->MovementProxy:
	var scope = Profiler.scope(self, "movement_proxy", [])

	return get_workshop_node("ViewportSizer/MainViewport/Root/MovementProxy") as MovementProxy

func resize_proxy()->ResizeProxy:
	var scope = Profiler.scope(self, "resize_proxy", [])

	return get_workshop_node("ViewportSizer/MainViewport/Root/MovementProxy/ResizeProxy") as ResizeProxy

func coordinate_space()->CoordinateSpace:
	var scope = Profiler.scope(self, "coordinate_space", [])

	return get_workshop_node("ViewportSizer/MainViewport/ObjectMovement/CoordinateSpace") as CoordinateSpace

func mouse_plane_move_handler()->MousePlaneMoveHandler:
	var scope = Profiler.scope(self, "mouse_plane_move_handler", [])

	return get_workshop_node("ViewportSizer/MainViewport/ObjectMovement/MousePlaneMoveHandler") as MousePlaneMoveHandler

func mouse_plane_rotate_handler()->MousePlaneRotateHandler:
	var scope = Profiler.scope(self, "mouse_plane_rotate_handler", [])

	return get_workshop_node("ViewportSizer/MainViewport/ObjectMovement/MousePlaneRotateHandler") as MousePlaneRotateHandler

func viewport_focus_manager()->ViewportFocusManager:
	var scope = Profiler.scope(self, "viewport_focus_manager", [])

	return get_workshop_node("ViewportSizer/MainViewport/ViewportFocusManager") as ViewportFocusManager

func hotkey_manager()->WorkshopHotkeyManager:
	var scope = Profiler.scope(self, "hotkey_manager", [])

	return get_workshop_node("HotkeyManager") as WorkshopHotkeyManager

func scene_manager()->WorkshopSceneManager:
	var scope = Profiler.scope(self, "scene_manager", [])

	return get_workshop_node("SceneManager") as WorkshopSceneManager

func copy_buffer()->WorkshopCopyBuffer:
	var scope = Profiler.scope(self, "copy_buffer", [])

	return get_workshop_node("CopyBuffer") as WorkshopCopyBuffer

func model_manager()->WorkshopModelManager:
	var scope = Profiler.scope(self, "model_manager", [])

	return get_workshop_node("ModelManager") as WorkshopModelManager

func workshop_camera()->Camera:
	var scope = Profiler.scope(self, "workshop_camera", [])

	return get_workshop_node("ViewportSizer/MainViewport/Root/WorkshopCamera") as Camera

func camera_focus_manager()->CameraFocusManager:
	var scope = Profiler.scope(self, "camera_focus_manager", [])

	return get_workshop_node("ViewportSizer/MainViewport/CameraFocusManager") as CameraFocusManager

func main_viewport()->Viewport:
	var scope = Profiler.scope(self, "main_viewport", [])

	return get_workshop_node("ViewportSizer/MainViewport") as Viewport

func main_viewport_root()->Node:
	var scope = Profiler.scope(self, "main_viewport_root", [])

	return get_workshop_node("ViewportSizer/MainViewport/Root")

func set_root_container()->Node:
	var scope = Profiler.scope(self, "set_root_container", [])

	return get_workshop_node("ViewportSizer/MainViewport/Root/SetRootContainer")

func set_root()->SetRoot:
	var scope = Profiler.scope(self, "set_root", [])

	var container = set_root_container()

	if container.get_child_count() == 0:
		return null

	return container.get_child(0) as SetRoot

func scene_tree_control()->SceneTreeControlNew:
	var scope = Profiler.scope(self, "scene_tree_control", [])

	return get_workshop_node("UIControls/SidebarTabs/WorkspaceTab/VSplitContainer/SceneTreeVBox/SceneTreeControl") as SceneTreeControlNew

func scene_tree_search()->LineEdit:
	var scope = Profiler.scope(self, "scene_tree_search", [])

	return get_workshop_node("UIControls/SidebarTabs/WorkspaceTab/VSplitContainer/SceneTreeVBox/Control/SceneTreeSearch") as LineEdit

func add_object_control()->AddObjectControl:
	var scope = Profiler.scope(self, "add_object_control", [])

	return get_workshop_node("UIControls/SidebarTabs/WorkspaceTab/VSplitContainer/SceneTreeVBox/PanelContainer/MarginContainer/AddObjectControl") as AddObjectControl

func viewport_control()->Control:
	var scope = Profiler.scope(self, "viewport_control", [])

	return get_workshop_node("UIControls/Viewports") as Control

func texture_property_overlay()->TexturePropertyOverlay:
	var scope = Profiler.scope(self, "texture_property_overlay", [])

	return get_workshop_node("UIControls/Viewports/TexturePropertyOverlay") as TexturePropertyOverlay

func ui()->Control:
	var scope = Profiler.scope(self, "ui", [])

	return get_workshop_node("UIControls") as Control

func main_viewport_texture()->TextureRect:
	var scope = Profiler.scope(self, "main_viewport_texture", [])

	return get_workshop_node("UIControls/Viewports/MainViewportTexture") as TextureRect

func hovered_node()->HoveredNode:
	var scope = Profiler.scope(self, "hovered_node", [])

	return get_workshop_node("HoveredNode") as HoveredNode

func selected_nodes()->SelectedNodes:
	var scope = Profiler.scope(self, "selected_nodes", [])

	return get_workshop_node("SelectedNodes") as SelectedNodes

func group_manager()->GroupManager:
	var scope = Profiler.scope(self, "group_manager", [])

	return get_workshop_node("ViewportSizer/MainViewport/GroupManager") as GroupManager

func tool_bar()->ToolBar:
	var scope = Profiler.scope(self, "tool_bar", [])

	return get_workshop_node("UIControls/ToolBar") as ToolBar

func tool_buttons()->ToolButtons:
	var scope = Profiler.scope(self, "tool_buttons", [])

	return get_workshop_node("UIControls/ToolBar/HBoxContainer/ScrollContainer/Buttons/ToolButtons") as ToolButtons

func edit_bar()->PanelContainer:
	var scope = Profiler.scope(self, "edit_bar", [])

	return get_workshop_node("UIControls/EditBar") as PanelContainer

func menu_bar()->PanelContainer:
	var scope = Profiler.scope(self, "menu_bar", [])

	return get_workshop_node("UIControls/MenuBar") as PanelContainer

func paint_manager()->PaintManager:
	var scope = Profiler.scope(self, "paint_manager", [])

	return get_workshop_node("ViewportInputManager/Modal/PaintManager") as PaintManager

func paint_color_manager()->PaintColorManager:
	var scope = Profiler.scope(self, "paint_color_manager", [])

	return get_workshop_node("ViewportSizer/MainViewport/PaintColorManager") as PaintColorManager

func property_inspector_model()->InspectorPropertyModel:
	var scope = Profiler.scope(self, "property_inspector_model", [])

	return get_workshop_node("UIControls/SidebarTabs/WorkspaceTab/VSplitContainer/PropertiesVBox/PanelContainer/PropertyInspector/InspectorPropertyModel") as InspectorPropertyModel

func environment_inspector_model()->InspectorPropertyModel:
	var scope = Profiler.scope(self, "environment_inspector_model", [])

	return get_workshop_node("UIControls/SidebarTabs/EnvironmentTab/EnvironmentVBox/EnvironmentInspector/InspectorPropertyModel") as InspectorPropertyModel

func translate_gizmo(positive:bool)->Spatial:
	var scope = Profiler.scope(self, "translate_gizmo", [positive])

	if positive:
		return get_workshop_node("ViewportSizer/MainViewport/Root/DragGizmo/PosTranslateGizmo") as Spatial
	else :
		return get_workshop_node("ViewportSizer/MainViewport/Root/DragGizmo/NegTranslateGizmo") as Spatial

func rotate_gizmo()->Spatial:
	var scope = Profiler.scope(self, "rotate_gizmo", [])

	return get_workshop_node("ViewportSizer/MainViewport/Root/DragGizmo/RotateGizmo") as Spatial

func scale_gizmo(positive:bool)->Spatial:
	var scope = Profiler.scope(self, "scale_gizmo", [positive])

	if positive:
		return get_workshop_node("ViewportSizer/MainViewport/Root/DragGizmo/PosScaleGizmo") as Spatial
	else :
		return get_workshop_node("ViewportSizer/MainViewport/Root/DragGizmo/NegScaleGizmo") as Spatial

func color_picker_popup()->Popup:
	var scope = Profiler.scope(self, "color_picker_popup", [])

	return get_workshop_node("UIControls/ColorPopup") as Popup

func color_picker()->BrickHillColorPicker:
	var scope = Profiler.scope(self, "color_picker", [])

	return get_workshop_node("UIControls/ColorPopup/PanelContainer/ColorPicker") as BrickHillColorPicker

func box_selector()->BoxSelector:
	var scope = Profiler.scope(self, "box_selector", [])

	return get_workshop_node("ViewportSizer/MainViewport/Root/BoxSelector") as BoxSelector

func bandbox_selector()->BandBoxSelector:
	var scope = Profiler.scope(self, "bandbox_selector", [])

	return get_workshop_node("ViewportSizer/MainViewport/Root/BandBoxSelector") as BandBoxSelector

func file_dialog()->Node:
	var scope = Profiler.scope(self, "file_dialog", [])

	return get_workshop_node("UIControls/FileDialog") as Node

func snap_to_face_manager()->SnapToFaceManager:
	var scope = Profiler.scope(self, "snap_to_face_manager", [])

	return get_workshop_node("ViewportSizer/MainViewport/SnapToFaceManager") as SnapToFaceManager

func scene_loader()->WorkshopSceneLoader:
	var scope = Profiler.scope(self, "scene_loader", [])

	return get_workshop_node("SceneManager/SceneLoader") as WorkshopSceneLoader

func legacy_loader()->WorkshopLegacyLoader:
	var scope = Profiler.scope(self, "legacy_loader", [])

	return get_workshop_node("SceneManager/LegacyLoader") as WorkshopLegacyLoader

func world_grid()->WorldGrid:
	var scope = Profiler.scope(self, "world_grid", [])

	return get_workshop_node("ViewportSizer/MainViewport/Root/WorldGrid") as WorldGrid

func camera_widget()->CameraWidget:
	var scope = Profiler.scope(self, "camera_widget", [])

	return get_workshop_node("UIControls/Viewports/CameraWidget") as CameraWidget

func color_popup()->Popup:
	var scope = Profiler.scope(self, "color_popup", [])

	var color_picker_manager = color_picker_manager()
	if color_picker_manager:
		if color_picker_manager.color_picker_popup:
			return color_picker_manager.color_picker_popup as Popup

	return get_workshop_node("UIControls/ColorPopup") as Popup

func material_popup()->Popup:
	var scope = Profiler.scope(self, "material_popup", [])

	return get_workshop_node("UIControls/MaterialPopup") as Popup

func surface_popup()->Popup:
	var scope = Profiler.scope(self, "surface_popup", [])

	return get_workshop_node("UIControls/SurfacePopup") as Popup

func main_menu()->PopupMenu:
	var scope = Profiler.scope(self, "main_menu", [])

	return get_workshop_node("UIControls/MainMenu") as PopupMenu

func color_picker_manager()->ColorPickerManager:
	var scope = Profiler.scope(self, "color_picker_manager", [])

	return get_workshop_node("ColorPickerManager") as ColorPickerManager

func eyedropper_manager()->EyedropperManager:
	var scope = Profiler.scope(self, "eyedropper_manager", [])

	return get_workshop_node("EyedropperManager") as EyedropperManager

func sidebar_tabs()->SidebarTabContainer:
	var scope = Profiler.scope(self, "sidebar_tabs", [])

	return get_workshop_node("UIControls/SidebarTabs") as SidebarTabContainer

func sidebar_dock()->RemoteRect:
	var scope = Profiler.scope(self, "sidebar_dock", [])

	return get_workshop_node("UILayout/BarViewportSplit/BarEditorSplit/VBoxContainer/ViewportRect/ViewportHSplit/SidebarDock") as RemoteRect

func graphics_settings_popup()->Popup:
	var scope = Profiler.scope(self, "graphics_settings_popup", [])

	return get_workshop_node("UIControls/GraphicsSettings") as Popup

func surface_picker()->SurfacePicker:
	var scope = Profiler.scope(self, "surface_picker", [])

	return get_workshop_node("UIControls/SurfacePopup/PanelContainer/SurfacePicker") as SurfacePicker

func material_picker()->MaterialPicker:
	var scope = Profiler.scope(self, "material_picker", [])

	return get_workshop_node("UIControls/MaterialPopup/PanelContainer/MaterialPicker") as MaterialPicker

func paint_surface_manager()->PaintSurfaceManager:
	var scope = Profiler.scope(self, "paint_surface_manager", [])

	return get_workshop_node("ViewportSizer/MainViewport/PaintSurfaceManager") as PaintSurfaceManager

func paint_material_manager()->PaintMaterialManager:
	var scope = Profiler.scope(self, "paint_material_manager", [])

	return get_workshop_node("ViewportSizer/MainViewport/PaintMaterialManager") as PaintMaterialManager

func alert_popup()->Popup:
	var scope = Profiler.scope(self, "alert_popup", [])

	return get_workshop_node("UIControls/AlertPopup") as Popup

func alert_button()->Button:
	var scope = Profiler.scope(self, "alert_button", [])

	return get_workshop_node("UIControls/AlertPopup/AlertVBox/AlertButtonHBox/AlertButton") as Button

func viewport_compositor()->ViewportSizer:
	var scope = Profiler.scope(self, "viewport_compositor", [])

	return get_workshop_node("ViewportSizer") as ViewportSizer

func recent_files_list()->RecentFilesList:
	var scope = Profiler.scope(self, "recent_files_list", [])

	return get_workshop_node("UIControls/SidebarTabs/FileTab/MarginContainer/VBoxContainer/RecentFilesScroll/RecentFiles") as RecentFilesList

func backups_list()->BackupsList:
	var scope = Profiler.scope(self, "backups_list", [])

	return get_workshop_node("UIControls/SidebarTabs/FileTab/MarginContainer/VBoxContainer/BackupsScroll/Backups") as BackupsList

func file_tab_header()->SidebarTabHeader:
	var scope = Profiler.scope(self, "file_tab_header", [])

	return get_workshop_node("UIControls/SidebarTabs/FileTab/FileHeader") as SidebarTabHeader

func workspace_tab_header()->SidebarTabHeader:
	var scope = Profiler.scope(self, "workspace_tab_header", [])

	return get_workshop_node("UIControls/SidebarTabs/WorkspaceTab/VSplitContainer/SceneTreeVBox/WorkspaceHeader") as SidebarTabHeader

func environment_tab_header()->SidebarTabHeader:
	var scope = Profiler.scope(self, "environment_tab_header", [])

	return get_workshop_node("UIControls/SidebarTabs/EnvironmentTab/EnvironmentVBox/EnvironmentHeader") as SidebarTabHeader
