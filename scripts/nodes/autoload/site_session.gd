extends Node

signal id_changed()
signal username_changed()

export (int) var id = 0 setget set_id
export (String) var username = "Guest" setget set_username

var _avatar_data:AvatarData setget , get_avatar_data

func get_avatar_data()->AvatarData:
	var scope = Profiler.scope(self, "get_avatar_data", [])

	return _avatar_data

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	_avatar_data = AvatarData.new()

func set_id(new_id:int)->void :
	var scope = Profiler.scope(self, "set_id", [new_id])

	if id != new_id:
		id = new_id
		_avatar_data.avatar_id = id
		emit_signal("id_changed")

func set_username(new_username:String)->void :
	var scope = Profiler.scope(self, "set_username", [new_username])

	if username != new_username:
		username = new_username
		emit_signal("username_changed")

func clear()->void :
	var scope = Profiler.scope(self, "clear", [])

	set_id(0)
	set_username("Guest")
