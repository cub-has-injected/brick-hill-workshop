class_name ImageTextureTGA

static func image_texture_tga(bytes:PoolByteArray)->ImageTexture:
	var image = Image.new()
	var result = image.load_tga_from_buffer(bytes)
	assert (result == OK, "Load TGA Error: %s" % [result])
	var asset = ImageTexture.new()
	asset.create_from_image(image)
	return asset
