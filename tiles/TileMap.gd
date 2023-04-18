extends TileMap


@export_node_path(CharacterBody2D) var player_path
@onready var player = get_node(player_path)
@onready var offsetter = player.get_node("YOffset")

var depth = 0.0
var smoothed_depth = 0.0

func _process(delta):
	var player_tile_position = round(player.position) / 16
	
	
#	depth = get_cell_tile_data(0, player_tile_position, false).get_custom_data("depth")
	erase_cell(0, player_tile_position)
	
#	smoothed_depth = lerp(smoothed_depth, depth, 0.2)
	
#	offsetter.position = Vector2(0, depth)
	
