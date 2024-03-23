class_name ImageTexturePNG

static func image_texture_png(bytes:PoolByteArray)->ImageTexture:
	var image = Image.new()
	var result = image.load_png_from_buffer(bytes)
	assert (result == OK, "Load PNG Error: %s" % [result])
	var asset = ImageTexture.new()
	asset.create_from_image(image)
	return asset
