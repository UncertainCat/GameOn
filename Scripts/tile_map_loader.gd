extends TileMap

# Constants for tile IDs
const TILE_PASSABLE = 0
const TILE_IMPASSABLE = 1

# Path to the image file as a resource
@export var image_path: ImageTexture

# Custom signal to notify the parent node that the TileMapSource is ready
signal tilemap_ready

func _ready():
	# Hide the TileMapSource by setting its visibility to false
	visible = false

	# Check if image_path is valid
	if image_path == null:
		print("Image path is not set.")
		return

	# Load the image from the ImageTexture
	var image = image_path.get_image()
	if image == null:
		print("Failed to load image from resource.")
		return

	# Ensure the image is in the correct format
	image.convert(Image.FORMAT_RGBA8)
	
	# Get the size of the image
	var width = image.get_width()
	var height = image.get_height()
	
	var used_cells = get_used_cells(0)
	
	# Get cell size for coordinate transformation
	var cell_size = Vector2(64, 32)  # Assuming 64x32 isometric tiles, adjust as necessary
	
	# Iterate through each used cell in the TileMap
	for cell in used_cells:
		var world_coords = map_to_local(cell) + cell_size / 2
		var image_x = int(world_coords.x)
		var image_y = int(world_coords.y)

		# Make sure the coordinates are within the image bounds
		if image_x >= 0 and image_x < width and image_y >= 0 and image_y < height:
			var color = image.get_pixel(image_x, image_y)
			
			var tile_id = TILE_PASSABLE
			if color.r > 0.5 and color.a > 0.5:  # Check if the pixel is red and not transparent
				tile_id = TILE_IMPASSABLE
			
			# Set the tile in the TileMap
			set_cell(0, cell, tile_id, Vector2i(0, 0), 0)
	
	# Defer the signal emission to ensure it occurs after the scene tree is fully ready
	call_deferred("emit_signal", "tilemap_ready")
