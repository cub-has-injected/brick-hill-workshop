class_name ImageTextureWEBP

static func image_texture_webp(bytes:PoolByteArray)->ImageTexture:
	var image = Image.new()
	var result = image.load_webp_from_buffer(bytes)
	assert (result == OK, "Load WEBP Error: %s" % [result])
	var asset = ImageTexture.new()
	asset.create_from_image(image)
	return asset
