class_name ImageTextureJPG

static func image_texture_jpg(bytes:PoolByteArray)->ImageTexture:
	var image = Image.new()
	var result = image.load_jpg_from_buffer(bytes)
	assert (result == OK, "Load JPG Error: %s" % [result])
	var asset = ImageTexture.new()
	asset.create_from_image(image)
	return asset
