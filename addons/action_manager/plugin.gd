class_name ActionManagerPlugin
extends EditorPlugin
tool 

func _enter_tree()->void :
	add_autoload_singleton("ActionManager", "res://addons/action_manager/scripts/action_manager.gd")

func _exit_tree()->void :
	remove_autoload_singleton("ActionManager")
