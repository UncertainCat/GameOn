extends TileMap

# Constants for tile IDs
const TILE_PASSABLE = 0
const TILE_IMPASSABLE = 1

# Path to the image file as a resource
@export var image_texture: ImageTexture

# Custom signal to notify the parent node that the TileMapSource is ready
signal tilemap_ready

func _ready():
	# Hide the TileMapSource by setting its visibility to false
	visible = false

	# Check if image_texture is valid
	if image_texture == null:
		print("Image texture is not set.")
		return

	# Get the image from the ImageTexture
	var image = image_texture.get_image()
	if image == null:
		print("Failed to load image from ImageTexture.")
		return

	# Ensure the image is in the correct format
	image.convert(Image.FORMAT_RGBA8)

	# Get the size of the image
	var width = image.get_width()
	var height = image.get_height()

	print("Image loaded successfully. Width: ", width, ", Height: ", height)

	# Iterate through each pixel in the image
	for y in range(height):
		for x in range(width):
			var color = image.get_pixel(x, y)

			var tile_id = TILE_PASSABLE
			if color.r > 0.5 and color.a > 0.5:  # Check if the pixel is red and not transparent
				tile_id = TILE_IMPASSABLE

			# Calculate the cell coordinates in the TileMap
			var cell = Vector2i(x, y)

			# Set the tile in the TileMap
			set_cell(0, cell, tile_id)

	# Defer the signal emission to ensure it occurs after the scene tree is fully ready
	call_deferred("emit_signal", "tilemap_ready")
