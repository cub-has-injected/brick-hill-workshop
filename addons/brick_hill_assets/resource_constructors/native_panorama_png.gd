class_name NativePanoramaPNG

static func native_panorama_png(bytes:PoolByteArray)->NativePanorama:
	var image = Image.new()
	var result = image.load_png_from_buffer(bytes)

	assert (result == OK, "Load PNG Error: %s" % [result])

	var asset = ImageTexture.new()
	asset.create_from_image(image)

	var panorama = NativePanorama.new()
	panorama.set_panorama_texture(asset)

	return panorama
