class_name AssetTexture
extends Asset
tool 

const BASE_DIR: = "user://"
const PNG_DIR: = "assets/png/"
const RESOURCE_EXTENSION: = "res"

export (ImageTexture) var asset_png:ImageTexture

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	asset_png = ImageTexture.new()

	if not _dir.dir_exists(PNG_DIR):
		_dir.make_dir_recursive(PNG_DIR)

func load_png(png:Image)->void :
	var scope = Profiler.scope(self, "load_png", [png])

	asset_png.create_from_image(png, ImageTexture.FLAG_MIPMAPS | ImageTexture.FLAG_REPEAT | ImageTexture.FLAG_FILTER | ImageTexture.FLAG_ANISOTROPIC_FILTER | ImageTexture.FLAG_CONVERT_TO_LINEAR)
	emit_signal("changed")

func update_asset()->void :
	var scope = Profiler.scope(self, "update_asset", [])

	if asset_id == 0:
		clear_asset()
		return 

	var target_asset = "%s%s.%s" % [PNG_DIR, asset_id, RESOURCE_EXTENSION]
	print_debug("Checking cache for PNG asset: %s" % [target_asset])
	if _dir.file_exists(target_asset):
		print_debug("Cache hit")
		var png_loader = ResourceLoader.load_interactive("%s%s" % [BASE_DIR, target_asset], "Image")
		while true:
			yield (Engine.get_main_loop(), "idle_frame")
			var result = png_loader.poll()
			if result == ERR_FILE_EOF:
				break

		var png = png_loader.get_resource() as Image
		yield (Engine.get_main_loop(), "idle_frame")
		if png:
			print("Loaded PNG: %s" % [png])
			load_png(png)
			yield (Engine.get_main_loop(), "idle_frame")
			property_list_changed_notify()
			return 
	else :
		print_debug("Cache miss")
		pass



func request_success_callback(response_body:PoolByteArray, metadata:Dictionary)->void :
	var scope = Profiler.scope(self, "request_success_callback", [response_body, metadata])

	assert (metadata.asset_id != 0)
	var png_image = Image.new()
	png_image.load_png_from_buffer(response_body)

	yield (Engine.get_main_loop(), "idle_frame")

	if png_image.get_format() != Image.FORMAT_RGBA8:
		png_image.convert(Image.FORMAT_RGBA8)
		yield (Engine.get_main_loop(), "idle_frame")

	ResourceSaver.save("%s%s%s.%s" % [BASE_DIR, PNG_DIR, metadata.asset_id, RESOURCE_EXTENSION], png_image)

	yield (Engine.get_main_loop(), "idle_frame")

	if metadata.asset_id == asset_id:
		load_png(png_image)
	else :
		clear_asset()

func clear_asset()->void :
	var scope = Profiler.scope(self, "clear_asset", [])

	var image = Image.new()
	image.create(1, 1, false, Image.FORMAT_RGBA8)
	asset_png.create_from_image(image)
	emit_signal("changed")
