extends TileMap

# Constants for tile IDs
const TILE_PASSABLE = 0
const TILE_IMPASSABLE = 1

# Path to the image file as a resource
@export var terrain_key: Image

# Custom signal to notify the parent node that the TileMapSource is ready
signal tilemap_ready

func _ready():
	# Hide the TileMapSource by setting its visibility to false
	visible = false

	assert(terrain_key != null, "Failed to load image from ImageTexture.")

	# Ensure the image is in the correct format
	terrain_key.convert(Image.FORMAT_RGBA8)

	# Get the size of the image
	var width = terrain_key.get_width()
	var height = terrain_key.get_height()
	assert(width > 0 and height > 0, "Image has invalid dimensions.")

	print("Image loaded successfully. Width: ", width, ", Height: ", height)

	# Get the tile size from the TileMap's TileSet
	var tile_size = tile_set.tile_size
	assert(tile_size.x > 0 and tile_size.y > 0, "Tile size is invalid.")

	# Iterate through each active cell in the TileMap
	for cell in get_used_cells(0):
		var local_position = map_to_local(cell)
		print(local_position)
		
		# Ensure the position is within image bounds
		var tile_id = TILE_PASSABLE
		if local_position.x < width and local_position.y < height:
			var color = terrain_key.get_pixelv(local_position)
			if color.r > 0.5 and color.a > 0.5:  # Check if the pixel is red and not transparent
				tile_id = TILE_IMPASSABLE
				print("found an impassable tile at ", cell)
		else:
			tile_id = TILE_IMPASSABLE
		
		set_cell(0, cell, tile_id)

	# Defer the signal emission to ensure it occurs after the scene tree is fully ready
	call_deferred("emit_signal", "tilemap_ready")
