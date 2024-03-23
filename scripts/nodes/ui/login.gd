extends Control

signal load_scene(packed_scene)

func get_error_label()->Label:
	var scope = Profiler.scope(self, "get_error_label", [])

	return get_node("MarginContainer/LoginBox/MarginContainer/HBoxContainer/LoginMenuVBox/CenterContainer/LoginVBox/ErrorLabel") as Label

func get_login_vbox()->VBoxContainer:
	var scope = Profiler.scope(self, "get_login_vbox", [])

	return get_node("MarginContainer/LoginBox/MarginContainer/HBoxContainer/LoginMenuVBox/CenterContainer/LoginVBox") as VBoxContainer

func get_main_menu_vbox()->VBoxContainer:
	var scope = Profiler.scope(self, "get_main_menu_vbox", [])

	return get_node("MarginContainer/LoginBox/MarginContainer/HBoxContainer/LoginMenuVBox/CenterContainer/MainMenuVBox") as VBoxContainer

func get_message_hbox()->HBoxContainer:
	var scope = Profiler.scope(self, "get_message_hbox", [])

	return get_node("MarginContainer/LoginBox/MarginContainer/HBoxContainer/LoginMenuVBox/CenterContainer/MessageHBox") as HBoxContainer

func get_message_label()->Label:
	var scope = Profiler.scope(self, "get_message_label", [])

	return get_node("MarginContainer/LoginBox/MarginContainer/HBoxContainer/LoginMenuVBox/CenterContainer/MessageHBox/Label") as Label

func get_open_workshop_button()->Button:
	var scope = Profiler.scope(self, "get_open_workshop_button", [])

	return get_node("MarginContainer/LoginBox/MarginContainer/HBoxContainer/LoginMenuVBox/CenterContainer/MainMenuVBox/OpenWorkshopButtonRect/OpenWorkshopButton") as Button

func get_loading_box_label()->Label:
	var scope = Profiler.scope(self, "get_loading_box_label", [])

	return get_node("MarginContainer/LoginBox/MarginContainer/HBoxContainer/SystemVBox/LoadingBox/MarginContainer/VBoxContainer/Label") as Label

func get_loading_box_progress_bar()->ProgressBar:
	var scope = Profiler.scope(self, "get_loading_box_progress_bar", [])

	return get_node("MarginContainer/LoginBox/MarginContainer/HBoxContainer/SystemVBox/LoadingBox/MarginContainer/VBoxContainer/ProgressBar") as ProgressBar

func set_message(new_message:String)->void :
	var scope = Profiler.scope(self, "set_message", [new_message])

	get_message_label().text = new_message

func set_error(new_error:String)->void :
	var scope = Profiler.scope(self, "set_error", [new_error])

	var error_label = get_error_label()
	error_label.text = new_error
	error_label.visible = true

func hide_error()->void :
	var scope = Profiler.scope(self, "hide_error", [])

	var error_label = get_error_label()
	error_label.text = ""
	error_label.visible = false

func show_message()->void :
	var scope = Profiler.scope(self, "show_message", [])

	$LoginBoxAnimationPlayer.play("show_message")

func play_error()->void :
	var scope = Profiler.scope(self, "play_error", [])

	$LoginBoxAnimationPlayer.play("error")

func play_logout()->void :
	var scope = Profiler.scope(self, "play_logout", [])

	$LoginBoxAnimationPlayer.play("logout")

func show_main_menu()->void :
	var scope = Profiler.scope(self, "show_main_menu", [])

	$LoginBoxAnimationPlayer.play("show_main_menu")

func show_system_panel()->void :
	var scope = Profiler.scope(self, "show_system_panel", [])

	$SystemBoxAnimationPlayer.play("show_system_panel")

func hide_system_panel()->void :
	var scope = Profiler.scope(self, "hide_system_panel", [])

	$SystemBoxAnimationPlayer.play("hide_system_panel")

func is_system_panel_visible()->bool:
	var scope = Profiler.scope(self, "is_system_panel_visible", [])

	var assigned_animation = $SystemBoxAnimationPlayer.assigned_animation
	var is_playing = $SystemBoxAnimationPlayer.is_playing()
	return assigned_animation == "show_system_panel" and not is_playing

func try_login()->void :
	SiteSession.id = 1
	SiteSession.username = "brick-luke"
	
	emit_signal("load_scene", preload("res://scenes/workshop.tscn"))
	

func login_success()->void :
	var scope = Profiler.scope(self, "login_success", [])

	BrickHillAuth.disconnect("login_error", self, "login_error")
	fetch_user_info()

func login_error(error:String)->void :
	var scope = Profiler.scope(self, "login_error", [error])

	BrickHillAuth.disconnect("login_success", self, "login_success")
	printerr(error)
	set_error(error)
	play_error()


func fetch_user_info()->void :
	var scope = Profiler.scope(self, "fetch_user_info", [])

	print_debug("Fetching user info...")
	set_message("Fetching user info...")

	var access_token = BrickHillAuth.get_access_token()
	if access_token.empty():
		user_info_failed("Invalid access token")
		return 

	HTTPManager.queue_get(
		"api.brick-hill.com", 
		"/v1/auth/currentUser", 
		["Authorization: Bearer %s" % [access_token]], 
		funcref(self, "user_info_success"), 
		funcref(self, "user_info_failed")
	)

func user_info_success(response_body:PoolByteArray, metadata:Dictionary)->void :
	var scope = Profiler.scope(self, "user_info_success", [response_body, metadata])

	var response_string = response_body.get_string_from_ascii()
	var parse_result = JSON.parse(response_string)
	var info_result = parse_result.result

	print_debug("User info: %s" % [info_result])

	SiteSession.id = info_result.user.id
	SiteSession.username = info_result.user.username

	set_message("Login successful.")
	show_main_menu()
	show_system_panel()

	UpdateManager.fetch_site_updates("debug")
	UpdateManager.fetch_site_updates("release")


func user_info_failed(error:String)->void :
	var scope = Profiler.scope(self, "user_info_failed", [error])

	printerr(error)
	set_error(error)
	play_error()


func quit_game()->void :
	var scope = Profiler.scope(self, "quit_game", [])

	get_tree().quit()


func open_workshop()->void :
	var scope = Profiler.scope(self, "open_workshop", [])

	emit_signal("load_scene", preload("res://scenes/workshop.tscn"))

func logout()->void :
	var scope = Profiler.scope(self, "logout", [])

	BrickHillAuth.clear_access_token()
	if is_system_panel_visible():
		hide_system_panel()
	play_logout()
	yield ($LoginBoxAnimationPlayer, "animation_finished")
	SiteSession.clear()

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	var label:String
	var ready: = false
	if BuiltInAssets.get_load_progress() == 1.0:
		label = "Built-in content loaded."
		ready = false
	else :
		label = "Loading built-in content..."
		ready = true

	get_open_workshop_button().disabled = ready
	get_loading_box_label().text = label
	get_loading_box_progress_bar().value = BuiltInAssets.get_load_progress()
